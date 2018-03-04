INFOPLIST_FULL_PATH="${TARGET_BUILD_DIR}"/"${INFOPLIST_PATH}"

status=$(git status --porcelain 2> /dev/null)
if [[ "$status" != "" ]]; then
git_dirty='dirty'
else
git_dirty='clean'
fi
/usr/libexec/PlistBuddy -c "Set :GIT_COMMIT `git rev-parse HEAD`" "${INFOPLIST_FULL_PATH}"
/usr/libexec/PlistBuddy -c "Set :GIT_STATUS ${git_dirty}" "${INFOPLIST_FULL_PATH}"
/usr/libexec/PlistBuddy -c "Set :BUDDYBUILD_BUILD_NUMBER ${BUDDYBUILD_BUILD_NUMBER}" "${INFOPLIST_FULL_PATH}"
