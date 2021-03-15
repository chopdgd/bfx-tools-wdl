
version 1.0
# -------------------------------------------------------------------------------------------------
# Task to handle Novoalign userString selection based on sequencing platfrom
# -------------------------------------------------------------------------------------------------

task SelectPlatform {
  input {
    String platform
    Array[String] novaseq_platforms = ["DGDNovaSeq"]

    # UserStrings based on sequencing platform
    String novaseq_userString = '"-i PE 240,150 -r All 5 -R 60 -t 15,2 -H 20 99999 --hlimit 7 --trim3HP ACGT -p 5,20 -x 6 --softclip 45,30 -v 70 --pechimera off -k"'
    String hiseq_userString = '"-i PE 240,150 -r All 5 -R 60 -t 15,2 -H 20 99999 --hlimit 7 --trim3HP ACGT -p 5,20 -x 6 --softclip 45,30 -v 70 --pechimera off -k"'

    # Run time variables
    Float memory = 12
    Int cpu = 1
    Array[String] modules = []
  }

  command <<<
    if [[ "~{sep=" " novaseq_platforms}" =~ "~{platform}" ]]
    then
      USERSTRING=~{novaseq_userString}
    else
      USERSTRING=~{hiseq_userString}
    fi

    echo "$USERSTRING"
  >>>

  output {
    String userString = read_lines(stdout())[0]
  }

  meta {
    author: "Tolga Ayazseven"
    email: "ayazsevent@email.chop.edu"
    version: "0.1.0"
  }
}
