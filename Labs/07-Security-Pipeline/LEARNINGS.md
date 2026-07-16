# Learnings

This is where i document my learning per project in raw format for transparency and genuine showcasing of information retention when building projects.

## Decisions i made and errors i ran into

Used `subscription_id` with no default so the caller would have to supply their own value. It cant have a universal default, if i were to hardcode my sub ID, it would fail immediately for anyone else except me.

Wanted to use networking module for vnet/subnet creation to be used for the VM instead of writing everything from 0, but ran into an issue where i couldnt call it directly since it lives in a seperate repo. So i opted to reference the module from the Git source.

Pinned it to `ref=main` so that when i ran 'terraform init' it would fetch whatever was currently on the main branch. So if i were to update the module later and push it to main, it would automatically pick those changes. However it could break it unexpectedly. Another method would be to pin it to specific commit SHA which would then point it consistently to use that exact version of the module.

For now `ref=main` would be fine since i own both repos but at least now i know the difference.

Chose `standard_D2as_v6` SKU for the VM because its proven to be consistently available in the westeurope region for me and im not doing anything "special".

Note! Requires `Gen2` specifically to work with this image

`subscription_id variable` had typo which caused "no declaration found" error in the main.tf and "unexpected attribute" in tfvars.

Git module source URL had wrong repo name which caused repo not found during init. Need to double check more often.

Next i added SSH open rule deliberately to main.tf for checkov to then flag the code during the check.

Set the `soft_fail` to `false` so that any violation that would occur would block the deploy job.

Then added ssh public key secret to github

Ran the security scan and checkov marked more than i initially expected. 

The following was flagged with the addon being my explanations:

1. Network interfaces shouldnt use Public IPs because VM having a public IP would be vulnerable to attacks.
2. VM extension monitoring agent wasnt installed which meant that there would be no way to know whats happening with the VM internally.
3. module source should use tag or commit has not `ref=main` however it allows me to pull any future changes automatically, with the tradeoff being at the risk of breaking changes or security regressions without explicit approval. 

ref=main was interesting about being less stable than pinning to commit SHA.

Overall the point was to introduce violation into the code in order to see live how Checkov flags it.