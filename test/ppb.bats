#!/usr/bin/env bats

PPB="${BATS_TEST_DIRNAME}/../bin/ppb"
RSYNC_PORT=18730

setup_file() {
	RSYNCD_UPLOAD_DIR="${BATS_FILE_TMPDIR}/uploads"
	mkdir -p "${RSYNCD_UPLOAD_DIR}"
	cat > "${BATS_FILE_TMPDIR}/rsyncd.conf" <<EOF
port = ${RSYNC_PORT}
pid file = ${BATS_FILE_TMPDIR}/rsyncd.pid
log file = ${BATS_FILE_TMPDIR}/rsyncd.log

[upload]
	path = ${RSYNCD_UPLOAD_DIR}
	read only = no
	use chroot = no
EOF
	rsync --daemon --config="${BATS_FILE_TMPDIR}/rsyncd.conf"
	for i in {1..20}; do
		rsync rsync://localhost:${RSYNC_PORT}/ &>/dev/null && break
		sleep 0.1
	done
}

teardown_file() {
	local pidfile="${BATS_FILE_TMPDIR}/rsyncd.pid"
	if [[ -f "${pidfile}" ]]; then
		kill "$(cat "${pidfile}")" 2>/dev/null || true
	fi
}

setup() {
	FAKE_BIN_DIR="${BATS_TEST_TMPDIR}/bin"
	UPLOAD_DIR="${BATS_TEST_TMPDIR}/uploads"
	FAKE_CONF="${BATS_TEST_TMPDIR}/ppb.conf"
	FIXTURES_DIR="${BATS_TEST_TMPDIR}/fixtures"
	mkdir -p "${FAKE_BIN_DIR}" "${UPLOAD_DIR}" "${FIXTURES_DIR}"

	rm -rf "${BATS_FILE_TMPDIR}/uploads"
	ln -s "${UPLOAD_DIR}" "${BATS_FILE_TMPDIR}/uploads"

	# shim rsync
	cat > "${FAKE_BIN_DIR}/rsync" <<'RSYNC_EOF'
#!/usr/bin/env bash
args=("$@")
last="${args[-1]}"
path="${last#*:}"
args[-1]="rsync://localhost:RSYNC_PORT/upload/${path##*/}"
exec /usr/bin/rsync "${args[@]}"
RSYNC_EOF
	sed -i "s/RSYNC_PORT/${RSYNC_PORT}/" "${FAKE_BIN_DIR}/rsync"
	chmod +x "${FAKE_BIN_DIR}/rsync"

	cat > "${FAKE_CONF}" <<EOF
PPB_TARGET_HOST="user@testhost.example.com"
PPB_PATH_ON_HOST="some/path"
PPB_HTTP_PATH="cdn.example.com/paste"
EOF

	# not mocking clipboards for now...
	for tool in wl-copy xclip; do
		printf '#!/usr/bin/env bash\nexit 0\n' > "${FAKE_BIN_DIR}/${tool}"
		chmod +x "${FAKE_BIN_DIR}/${tool}"
	done

	echo "whatever 🥳" > "${FIXTURES_DIR}/plain.txt"
	printf 'foo \033[31mred\033[0m bar\n' > "${FIXTURES_DIR}/ansi.txt"
}

teardown() {
	rm -f "${BATS_FILE_TMPDIR}/uploads"
	mkdir -p "${BATS_FILE_TMPDIR}/uploads"
}
run_ppb() {
	run env \
		PATH="${FAKE_BIN_DIR}:${PATH}" \
		bash --norc --noprofile -c "
			.() { source '${FAKE_CONF}'; }
			source '${PPB}' \"\$@\"
		" ppb "$@"
}

uploaded_files() { find "${UPLOAD_DIR}" -type f; }

@test "-h exits 0 and prints usage" {
	run_ppb -h
	[[ "$status" -eq 0 ]]
	[[ "${output}" == *"Usage: "* ]]
}

@test "missing PPB_TARGET_HOST exits with error" {
	local bad_conf="${BATS_TEST_TMPDIR}/bad.conf"
	printf 'PPB_PATH_ON_HOST="some/path"\nPPB_HTTP_PATH="cdn.example.com"\n' > "${bad_conf}"

	run env PATH="${FAKE_BIN_DIR}:${PATH}" \
		bash --norc --noprofile -c "
			.() { source '${bad_conf}'; }
			source '${PPB}' \"\$@\"
		" ppb "${FIXTURES_DIR}/plain.txt"

	[[ "$status" -ne 0 ]]
	echo "$output" | grep -q "PPB_TARGET_HOST"
}

@test "plain file upload prints a URL" {
	run_ppb "${FIXTURES_DIR}/plain.txt"
	[[ "$status" -eq 0 ]]
}

@test "destination filename is derived from md5 of content" {
	local expected_hash
	expected_hash=$(md5sum "${FIXTURES_DIR}/plain.txt" | cut -c1-6)
	run_ppb "${FIXTURES_DIR}/plain.txt"
	[[ "$status" -eq 0 ]]
	uploaded=$(basename "$(uploaded_files)")
	[[ "${uploaded}" == "${expected_hash}"* ]]
}

@test "file with ANSI codes is converted and uploaded as .html" {
	run_ppb "${FIXTURES_DIR}/ansi.txt"
	[[ "$status" -eq 0 ]]
	uploaded=$(basename "$(uploaded_files)")
	[[ "${uploaded}" == *.html ]]
}

@test "same file content always produces the same URL" {
	run_ppb "${FIXTURES_DIR}/plain.txt"
	local url1
	url1=$(echo "$output" | grep "https://")

	rm -f "${UPLOAD_DIR}"/*
	run_ppb "${FIXTURES_DIR}/plain.txt"
	local url2
	url2=$(echo "$output" | grep "https://")

	[[ "$url1" == "$url2" ]]
}
