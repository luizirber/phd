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
    sources=expand('thesis/{rmd}.Rmd',
                   rmd=('index', '00-intro', '01-scaled', '02-index',
                        '03-gather', '04-distributed', '05-decentralized',
                        '06-conclusion', '07-appendix', '98-colophon', '99-references')),
    templates="thesis/template.tex",
    bibliography='thesis/bib/thesis.bib'
  shell: """
      cd thesis
      rm -f _main.Rmd
      R -e "options(tinytex.engine_args = '-shell-escape'); options(tinytex.verbose = TRUE); bookdown::render_book('index.Rmd', aggiedown::thesis_pdf(latex_engine = 'pdflatex'))"
      mv _book/_main.pdf _book/thesis.pdf
  """

rule extract_title_page:
  output: 'filing/title_page.pdf'
  input: 'thesis/_book/thesis.pdf'
  shell: "pdfjam {input} 1 -o {output}"

rule extract_abstract:
  output: 'filing/01_abstract.pdf'
  input: 'thesis/_book/thesis.pdf'
  shell: "pdfjam {input} 5 -o {output}"
