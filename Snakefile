rule all:
  input: 'thesis/_book/thesis.pdf'

rule install_deps:
  conda: 'envs/R.yml'
  shell: """
    TAR=/bin/tar R -e 'devtools::install_github("ryanpeek/aggiedown@ae99300d43bdccc16069efcc08198624c76eee0c", upgrade = "never")'
  """

rule start_thesis:
  conda: 'envs/R.yml'
  shell: """
    R -e "rmarkdown::draft('index.Rmd', template = 'UCD-Dissertation', package = 'aggiedown', create_dir = TRUE)"
  """

rule build_thesis:
  conda: 'envs/R.yml'
  output: 'thesis/_book/thesis.pdf'
  input:
    sources=expand('thesis/{rmd}.Rmd', rmd=('index', '00-intro', '01-chap1', '02-chap2', '03-chap3', '04-conclusion', '05-appendix', '98-colophon', '99-references')),
    bibliography='thesis/bib/thesis.bib'
  shell: """
      cd thesis
      R -e "bookdown::render_book('index.Rmd', aggiedown::thesis_pdf(latex_engine = 'xelatex'))"
      mv _book/_main.pdf _book/thesis.pdf
  """
