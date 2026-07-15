# Learnings

This is where i document my learning in raw format for transparency and genuine showcasing of information retention when building projects.

## AI got it right

## AI got it wrong

## Decisions ive made

Used 'subscription_id' with no default so the caller would have to supply their own value. It cant have a universal default, if i were to hardcode my sub ID, it would fail immediately for anyone else except me.

Wanted to use networking module for vnet/subnet creation to be used for the VM instead of writing everything from 0, but ran into an issue where i couldnt call it directly since it lives in a seperate repo. So i opted to reference the module from the Git source.

Pinned it to 'ref=main' so that when i ran 'terraform init' it would fetch whatever was currently on the main branch. So if i were to update the module later and push it to main, it would automatically pick those changes. However it could break it unexpectedly. Another method would be to pin it to specific commit SHA which would then point it consistently to use that exact version of the module.

For now 'ref=main' would be fine since i own both repos but at least now i know the difference.

Chose standard_D2as_v6 SKU for the VM because its proven to be consistently available in the westeurope region for me and im not doing anything "special".

Note! Requires Gen2 specifically to work with this image