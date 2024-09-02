{"payload":{"allShortcutsEnabled":false,"fileTree":{"pkgs/ida-free":{"items":[{"name":"default.nix","path":"pkgs/ida-free/default.nix","contentType":"file"},{"name":"srcs.json","path":"pkgs/ida-free/srcs.json","contentType":"file"},{"name":"update.sh","path":"pkgs/ida-free/update.sh","contentType":"file"}],"totalCount":3},"pkgs":{"items":[{"name":"ida-free","path":"pkgs/ida-free","contentType":"directory"},{"name":"kickoff","path":"pkgs/kickoff","contentType":"directory"},{"name":"triton","path":"pkgs/triton","contentType":"directory"},{"name":"default.nix","path":"pkgs/default.nix","contentType":"file"}],"totalCount":4},"":{"items":[{"name":"home-manager","path":"home-manager","contentType":"directory"},{"name":"nixos","path":"nixos","contentType":"directory"},{"name":"overlays","path":"overlays","contentType":"directory"},{"name":"pkgs","path":"pkgs","contentType":"directory"},{"name":".gitignore","path":".gitignore","contentType":"file"},{"name":"README.org","path":"README.org","contentType":"file"},{"name":"flake.lock","path":"flake.lock","contentType":"file"},{"name":"flake.nix","path":"flake.nix","contentType":"file"},{"name":"nixpkgs.nix","path":"nixpkgs.nix","contentType":"file"}],"totalCount":9}},"fileTreeProcessingTime":5.8391329999999995,"foldersToFetch":[],"reducedMotionEnabled":null,"repo":{"id":637357271,"defaultBranch":"master","name":"nix-config","ownerLogin":"0poss","currentUserCanPush":false,"isFork":false,"isEmpty":false,"createdAt":"2023-05-07T10:03:58.000Z","ownerAvatar":"https://avatars.githubusercontent.com/u/67114640?v=4","public":true,"private":false,"isOrgOwned":false},"symbolsExpanded":false,"treeExpanded":true,"refInfo":{"name":"56c6cde1246dd8779f0d31204da69ffc5c38a0d8","listCacheKey":"v0:1683453844.0","canEdit":false,"refType":"tree","currentOid":"56c6cde1246dd8779f0d31204da69ffc5c38a0d8"},"path":"pkgs/ida-free/update.sh","currentUser":null,"blob":{"rawLines":["#! /usr/bin/env nix-shell","#! nix-shell -i bash -p bash curl jq","","set -e","","urls=(","  https://out7.hex-rays.com/files/idafree82_linux.run","  https://out7.hex-rays.com/files/idafree82_mac.app.zip","  https://out7.hex-rays.com/files/arm_idafree82_mac.app.zip",")","","archs=(","  x86_64-linux","  x86_64-darwin","  aarch64-darwin",")","","hashes=()","for u in \"${urls[@]}\"; do","  hash=$(nix-prefetch-url $u)","  hashes=(\"${hashes[@]}\" \"$hash\")","done","","for ((i = 0; i < ${#urls[@]}; i++)); do","  echo '{\"key\":\"'${archs[i]}'\", \"value\":{\"url\":\"'${urls[i]}'\", \"sha256\":\"'${hashes[i]}'\"}}'","done | jq -s from_entries >pkgs/development/tools/analysis/ida-free/srcs.json"],"stylingDirectives":[[{"start":0,"end":25,"cssClass":"pl-c"},{"start":0,"end":2,"cssClass":"pl-c"}],[{"start":0,"end":36,"cssClass":"pl-c"},{"start":0,"end":2,"cssClass":"pl-c"}],[],[{"start":0,"end":3,"cssClass":"pl-c1"}],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[{"start":0,"end":3,"cssClass":"pl-k"},{"start":4,"end":5,"cssClass":"pl-smi"},{"start":6,"end":8,"cssClass":"pl-k"},{"start":9,"end":21,"cssClass":"pl-s"},{"start":9,"end":10,"cssClass":"pl-pds"},{"start":10,"end":20,"cssClass":"pl-smi"},{"start":20,"end":21,"cssClass":"pl-pds"},{"start":21,"end":22,"cssClass":"pl-k"},{"start":23,"end":25,"cssClass":"pl-k"}],[{"start":7,"end":29,"cssClass":"pl-s"},{"start":7,"end":9,"cssClass":"pl-pds"},{"start":26,"end":28,"cssClass":"pl-smi"},{"start":28,"end":29,"cssClass":"pl-pds"}],[{"start":10,"end":24,"cssClass":"pl-s"},{"start":10,"end":11,"cssClass":"pl-pds"},{"start":11,"end":23,"cssClass":"pl-smi"},{"start":23,"end":24,"cssClass":"pl-pds"},{"start":25,"end":32,"cssClass":"pl-s"},{"start":25,"end":26,"cssClass":"pl-pds"},{"start":26,"end":31,"cssClass":"pl-smi"},{"start":31,"end":32,"cssClass":"pl-pds"}],[{"start":0,"end":4,"cssClass":"pl-k"}],[],[{"start":0,"end":3,"cssClass":"pl-k"},{"start":4,"end":35,"cssClass":"pl-s"},{"start":4,"end":6,"cssClass":"pl-pds"},{"start":8,"end":9,"cssClass":"pl-k"},{"start":10,"end":11,"cssClass":"pl-c1"},{"start":15,"end":16,"cssClass":"pl-k"},{"start":17,"end":28,"cssClass":"pl-smi"},{"start":19,"end":20,"cssClass":"pl-k"},{"start":31,"end":33,"cssClass":"pl-k"},{"start":33,"end":35,"cssClass":"pl-pds"},{"start":35,"end":36,"cssClass":"pl-k"},{"start":37,"end":39,"cssClass":"pl-k"}],[{"start":2,"end":6,"cssClass":"pl-c1"},{"start":7,"end":17,"cssClass":"pl-s"},{"start":7,"end":8,"cssClass":"pl-pds"},{"start":16,"end":17,"cssClass":"pl-pds"},{"start":17,"end":28,"cssClass":"pl-smi"},{"start":28,"end":49,"cssClass":"pl-s"},{"start":28,"end":29,"cssClass":"pl-pds"},{"start":48,"end":49,"cssClass":"pl-pds"},{"start":49,"end":59,"cssClass":"pl-smi"},{"start":59,"end":74,"cssClass":"pl-s"},{"start":59,"end":60,"cssClass":"pl-pds"},{"start":73,"end":74,"cssClass":"pl-pds"},{"start":74,"end":86,"cssClass":"pl-smi"},{"start":86,"end":91,"cssClass":"pl-s"},{"start":86,"end":87,"cssClass":"pl-pds"},{"start":90,"end":91,"cssClass":"pl-pds"}],[{"start":0,"end":4,"cssClass":"pl-k"},{"start":5,"end":6,"cssClass":"pl-k"},{"start":26,"end":27,"cssClass":"pl-k"}]],"csv":null,"csvError":null,"dependabotInfo":{"showConfigurationBanner":false,"configFilePath":null,"networkDependabotPath":"/0poss/nix-config/network/updates","dismissConfigurationNoticePath":"/settings/dismiss-notice/dependabot_configuration_notice","configurationNoticeDismissed":null,"repoAlertsPath":"/0poss/nix-config/security/dependabot","repoSecurityAndAnalysisPath":"/0poss/nix-config/settings/security_analysis","repoOwnerIsOrg":false,"currentUserCanAdminRepo":false},"displayName":"update.sh","displayUrl":"https://github.com/0poss/nix-config/blob/56c6cde1246dd8779f0d31204da69ffc5c38a0d8/pkgs/ida-free/update.sh?raw=true","headerInfo":{"blobSize":"627 Bytes","deleteInfo":{"deleteTooltip":"You must be signed in to make or propose changes"},"editInfo":{"editTooltip":"You must be signed in to make or propose changes"},"ghDesktopPath":null,"gitLfsPath":null,"onBranch":false,"shortPath":"75a3ceb","siteNavLoginPath":"/login?return_to=https%3A%2F%2Fgithub.com%2F0poss%2Fnix-config%2Fblob%2F56c6cde1246dd8779f0d31204da69ffc5c38a0d8%2Fpkgs%2Fida-free%2Fupdate.sh","isCSV":false,"isRichtext":false,"toc":null,"lineInfo":{"truncatedLoc":"26","truncatedSloc":"21"},"mode":"file"},"image":false,"isCodeownersFile":null,"isPlain":false,"isValidLegacyIssueTemplate":false,"issueTemplateHelpUrl":"https://docs.github.com/articles/about-issue-and-pull-request-templates","issueTemplate":null,"discussionTemplate":null,"language":"Shell","languageID":346,"large":false,"loggedIn":false,"newDiscussionPath":"/0poss/nix-config/discussions/new","newIssuePath":"/0poss/nix-config/issues/new","planSupportInfo":{"repoIsFork":null,"repoOwnedByCurrentUser":null,"requestFullPath":"/0poss/nix-config/blob/56c6cde1246dd8779f0d31204da69ffc5c38a0d8/pkgs/ida-free/update.sh","showFreeOrgGatedFeatureMessage":null,"showPlanSupportBanner":null,"upgradeDataAttributes":null,"upgradePath":null},"publishBannersInfo":{"dismissActionNoticePath":"/settings/dismiss-notice/publish_action_from_dockerfile","dismissStackNoticePath":"/settings/dismiss-notice/publish_stack_from_file","releasePath":"/0poss/nix-config/releases/new?marketplace=true","showPublishActionBanner":false,"showPublishStackBanner":false},"rawBlobUrl":"https://github.com/0poss/nix-config/raw/56c6cde1246dd8779f0d31204da69ffc5c38a0d8/pkgs/ida-free/update.sh","renderImageOrRaw":false,"richText":null,"renderedFileInfo":null,"shortPath":null,"tabSize":8,"topBannersInfo":{"overridingGlobalFundingFile":false,"globalPreferredFundingPath":null,"repoOwner":"0poss","repoName":"nix-config","showInvalidCitationWarning":false,"citationHelpUrl":"https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-on-github/about-citation-files","showDependabotConfigurationBanner":false,"actionsOnboardingTip":null},"truncated":false,"viewable":true,"workflowRedirectUrl":null,"symbols":{"timed_out":false,"not_analyzed":false,"symbols":[]}},"copilotInfo":null,"copilotAccessAllowed":false,"csrf_tokens":{"/0poss/nix-config/branches":{"post":"YIJMS8-rbuq-bAn0CMZjoJ1D59cY7MXg9jRZk_8ZE53Ft57yMJdl_5NQWmrYXT7KD9u_Q-wTdU7M-wwyC2h2xw"},"/repos/preferences":{"post":"7_S4Q12aWO5v0mg0jYHQW5mp8sysAHGXrXBwmrGodBY4GB02YyzhccSRURjGsnJUtyI-j7Ds4JDz8zEcALGlgA"}}},"title":"nix-config/pkgs/ida-free/update.sh at 56c6cde1246dd8779f0d31204da69ffc5c38a0d8 · 0poss/nix-config"}