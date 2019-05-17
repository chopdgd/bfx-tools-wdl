# WDL Tasks for Bioinformatics tools

Standard tasks to run Bioinformatics tools using WDL

## How to run?

***Make sure you use Cromwell version 35 and above***

- running it directly: its slower so this is only recommended when you are testing subworkflows and not exome alignment
`java -Xmx8g -jar /DGD/clin-air/tools/cromwell/41/cromwell-41.jar run -i <test>.input.json -m <test>.metadata.json subworkflows/NovoAlign-FastQToBAM.wdl`


## How to use?

In your wdl workflows you can import directly like:

  `import "<url/to/raw/file.wdl" as ToolName`

## Contributing??

If you plan to contribute, make sure to activate our pre-commit hooks to validate changes to WDL by running:

  `make setup-githooks`
