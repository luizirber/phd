rule all:
  input: 'thesis/_book/thesis.pdf'

rule install_deps:
  conda: 'envs/R.yml'
  shell: """
    TAR=/bin/tar R -e 'devtools::install_github("ryanpeek/aggiedown@ae99300d43bdccc16069efcc08198624c76eee0c")'
  """

rule start_thesis:
  conda: 'envs/R.yml'
  shell: """
    R -e "rmarkdown::draft('index.Rmd', template = 'UCD-Dissertation', package = 'aggiedown', create_dir = TRUE)"
  """

rule build_thesis:
  conda: 'envs/R.yml'
  output: 'thesis/_book/thesis.pdf'
  shell: """
      cd thesis
      R -e "bookdown::render_book('index.Rmd', aggiedown::thesis_pdf(latex_engine = 'xelatex'))"
  """
