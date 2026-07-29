# Learnings

This is where i document my learning per project in raw format for transparency and genuine showcasing of information retention when building projects.

## Decisions i made and errors i ran into

Wanted to learn a bit more about Azure Devops so decided to rebuild Lab 7 security pipeline but in azure devops to figure out its ups and downs and how it differs from running pipelines in github.

Because checkov needs to know which folder to scan you need to use `$(Build.SourcesDirectory)` which is the built in variable for AZ Pipelines in .yaml to point it to the directory where the files are.

Had to postpone this one since my network is just too goddamn slow to be using azure dev ops UI.