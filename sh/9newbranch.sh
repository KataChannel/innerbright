read -p "Enter branch name: " branch_name
git checkout -b "$branch_name"
git push --set-upstream origin "$branch_name"