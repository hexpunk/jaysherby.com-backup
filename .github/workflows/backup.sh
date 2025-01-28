#! /bin/sh

set -e
set -u

# Delete all directories that are not hidden to avoid keeping deleted files.
find . -maxdepth 1 -type d -not -name '.*' -exec rm -r "{}" \;

# Download website and images, ignoring /hit and /upvote paths.
wget --wait=2 \
     --mirror \
     --page-requisites \
     --no-parent \
     --convert-links \
     --adjust-extension \
     --span-hosts \
     --domains="jaysherby.com,digitaloceanspaces.com" \
     --exclude-directories="hit,upvote" \
     -e robots=off \
     https://jaysherby.com

# Delete CSRF tokens since they'll change every page load.
# Delete last build date tag since it will change often.
# Delete "updated" dates that are always the current timestamp in feed pages.
find . -type f -name "*.html*" \
       -exec sed -i.bak '/<input.*name="csrfmiddlewaretoken".*>/d' {} \; \
       -exec sed -i.bak '/<lastBuildDate>.*<\/lastBuildDate>/d' {} \; \
       -exec sed -i.bak '/<updated>.*<\/updated>/d' {} \; \
       -exec rm {}.bak \;

# Detect any added, changed, or deleted files
if [ -n "$(git ls-files --modified --deleted --others)" ]; then
  git add -A
  git commit -m "Backup $(date)"
  git push origin main
fi
