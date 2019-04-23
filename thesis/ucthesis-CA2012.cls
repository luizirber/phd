% UCTHESIS DOCUMENT CLASS -- Release info is below.
%    for LaTeX version 2e - 11/3/94
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ucthesis-CA2012} [2012/05/08 Revision by Curtis Asplund of 1996/06/26 JTW's modification of 1994/10/31 v3.0 University of California Thesis Class]

\newif\ifproquest\proquestfalse
\DeclareOption{proquest}% sets electrons-only, proquest style
  {\proquesttrue}

%    ****************************************
%    *               OPTIONS                *
%    ****************************************
%
% Option values are now declared first thing.
% Options inclued 'Xpt [X=10,11,12]','final/draft','oneside/twoside',
% Defaults are set to 12 point, onesided, final (ie not draft) mode (BBF 10/31/94)


% options from uwthesis.cls

% ----  Timely loading of specific packages -----------------------------
%
\newif\if@natbib      % true if including natbib
  \@natbibfalse
\DeclareOption{natbib}% includes natbib package
  {\@natbibtrue}


% ----  Thesis is a modified (default 12pt) book style  -----------------
%

\def\@f@ntsize{12pt}
\DeclareOption{10pt}{\def\@f@ntsize{10pt}}
\DeclareOption{11pt}{\def\@f@ntsize{11pt}}
\DeclareOption{12pt}{\def\@f@ntsize{12pt}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}

\PassOptionsToClass{\@f@ntsize}{book}
\PassOptionsToClass{openany}{book}
\ProcessOptions
\LoadClass{book}

\ifproquest
  \typeout{Formatting for ProQuest}
  \@twosidefalse
  \@openrightfalse
\fi

\if@natbib
  \usepackage{natbib}
\fi

\newcommand\@draftmark{}
\newif\if@openright
\newif\if@ucmainmatter \@ucmainmattertrue
\DeclareOption{oneside}{\@twosidefalse \@mparswitchfalse}
\DeclareOption{twoside}{\@twosidetrue  \@mparswitchtrue}
\DeclareOption{draft}{\setlength\overfullrule{5pt}\renewcommand\@draftmark{1}}
\DeclareOption{final}{\setlength\overfullrule{0pt}\renewcommand\@draftmark{0}}
\DeclareOption{openright}{\if@twoside \@openrighttrue \else \@openrightfalse \fi}
\DeclareOption{openany}{\@openrightfalse}

\ExecuteOptions{12pt,oneside,final}
\ProcessOptions

%    ****************************************
%    *            Some Definitions          *
%    ****************************************

\@lowpenalty   51
\@medpenalty  151
\@highpenalty 301
% For single and double spacing
% \smallssp is used to produce tabular environments in the small font.
% \scriptsizessp is a still smaller version of the same thing.
\def\ssp{\def\baselinestretch{1.0}\large\normalsize}
\def\dsp{\def\baselinestretch{1.5}\large\normalsize}
\def\dsp{\def\baselinestretch{1.655}\large\normalsize}
\def\smallssp{\def\baselinestretch{1.0}\large\small}
\def\scriptsizessp{\def\baselinestretch{1.0}\large\scriptsize}

% PREPARING A FOREIGN LANGUAGE VERSION:
%
% This document style is for documents prepared in the English language.
% To prepare a version for another language, various English words must
% be replaced.  Many of the English words that required replacement are
% indicated below, where we give the name of the command in which the
% words appear, and which must be redefined, with the actual words
% underlined.
%
% Other English words that need replacement can be found in the macros
% supporting the title and approval pages.
%
\def\contentsname{Contents}
\def\listfigurename{List of Figures}
\def\listtablename{List of Tables}
\def\bibname{Bibliography}
\def\indexname{Index}
\def\figurename{Figure}
\def\tablename{Table}
\def\chaptername{Chapter}
\def\appendixname{Appendix}
\def\partname{Part}
\def\abstractname{Abstract}
\def\acknowledgename{Acknowledgements}
\def\disclaimername{Disclaimer}
\def\vitaename{Curriculum Vit\ae}
\def\@chapapp{\chaptername} % For use in the old 'book' style commands


%    ****************************************
%    *            PAGE STYLES               *
%    ****************************************
%  This section set the page size margins, header and footer according to the
%  UC recommendations
%
%
%\mark{{}{}}        % Initializes TeX's marks
\if@twoside         % If two-sided printing.
  \def\ps@headings{
      \def\@oddfoot{\rm\hfil\thepage\hfil}
      \def\@evenfoot{\rm\hfil\thepage\hfil}     % Page numbers on ALL pages.
      \def\@evenhead{\hfil\slshape\leftmark}%
      \def\@oddhead{{\slshape\rightmark}\hfil}%
      \let\@mkboth\markboth
    \def\chaptermark##1{%
      \markboth {\MakeUppercase{%
        \ifnum \c@secnumdepth >\m@ne
          \if@ucmainmatter
            \@chapapp\ \thechapter. \ %
          \fi
        \fi
        ##1}}{}}%
    \def\sectionmark##1{%
      \markright {\MakeUppercase{%
        \ifnum \c@secnumdepth >\z@
          \thesection. \ %
        \fi
        ##1}}}}
\else               % If one-sided printing.
  \def\ps@headings{%
    \def\@oddfoot{\rm\hfil\thepage\hfil}
    \def\@oddhead{{\slshape\rightmark}\hfil}%
    \let\@mkboth\markboth
    \def\chaptermark##1{%
      \markright {\MakeUppercase{%
        \ifnum \c@secnumdepth >\m@ne
          \if@ucmainmatter
            \@chapapp\ \thechapter. \ %
          \fi
        \fi
        ##1}}}}
\fi

% Definition of 'myheadings' page style.
%
\if@twoside         % If two-sided printing.
\def\ps@myheadings{\let\@mkboth\markboth
 \def\@oddfoot{\rm\hfil\thepage\hfil}
 \def\@evenfoot{\rm\hfil\thepage\hfil}     % Page numbers on ALL pages.
 \def\@evenhead{\hfil \slshape \leftmark}  %    Left heading.
 \def\@oddhead{{\slshape \rightmark}\hfil} %   Right heading.
 \def\chaptermark##1{\markboth {\uppercase{\ifnum \c@secnumdepth >\m@ne
 \@chapapp\ \thechapter. \ \fi} ##1}{}}%
 \def\sectionmark##1{\markright {\uppercase{\ifnum \c@secnumdepth >\z@
   \thesection. \ \fi} ##1}}}
\else               % If one-sided printing.
  \def\ps@myheadings{\let\@mkboth\markboth
  \def\@oddfoot{\rm\hfil\thepage\hfil}
  \def\@evenfoot{\rm\hfil\thepage\hfil}
  \def\@oddhead{{\slshape \leftmark}\hfil} % Heading.
  \def\chaptermark##1{\markboth {\uppercase{\ifnum \c@secnumdepth >\m@ne
  \@chapapp\ \thechapter. \ \fi} ##1}{}}}%
\fi

% Definition of 'plain' page style.
\def\ps@plain{\let\@mkboth\markboth
\def\@oddfoot{\rm\hfil\thepage\hfil}
\def\@evenfoot{\rm\hfil\thepage\hfil}           % page numbers in feet
\def\@oddhead{}\def\@evenhead{}
}
% Definition of 'empty' page style.
\def\ps@empty{\let\@mkboth\markboth
\def\@oddfoot{}\def\@evenfoot{}\def\@oddhead{}\def\@evenhead{}}

%    ****************************************
%    *             FRONT MATTER             *
%    ****************************************
%

% DECLARATIONS
%
% These macros are used to declare arguments needed for the
% construction of the front matter.

\def\degreemonth#1{\gdef\@degreemonth{#1}}  % degree month
\def\degreeyear#1{\gdef\@degreeyear{#1}}    % degree year
% \def\defensemonth#1{\gdef\@defensemonth{#1}}% defense month
% \def\defenseyear#1{\gdef\@defenseyear{#1}}  % defense year
\def\degree#1{\gdef\@degree{#1}}            % full (unabbreviated) name of the degree
\def\chair#1{\gdef\@chair{#1}}              % committee's chair
\def\othermemberA#1{\gdef\@othermemberA{#1}}% committe members, one per line
\def\othermemberB#1{\gdef\@othermemberB{#1}}
\def\othermemberC#1{\gdef\@othermemberC{#1}}
\def\othermemberD#1{\gdef\@othermemberD{#1}}
\def\othermembers#1{\gdef\@othermembers{#1}}%
\def\field#1{\gdef\@field{#1}}              % degree's field (e.g. Psychology, Computer Science)
\def\campus#1{\gdef\@campus{#1}}
\def\fmfont{\fontsize\@xiipt{14.5}\selectfont} % Set the font for frontmatter
\def\fmsmallfont{\fontsize\@xiipt{14pt}\selectfont}

% REPORT    type of report:Dissertation or dissertation or proposal etc...
\def\report#1{\gdef\@report{#1}}

% FRONTMATTER environment
%
% The FRONTMATTER environment makes sure that page numbering is set
% correctly (roman, lower-case, starting at 2) for the front matter.
% It also resets to arabic the page-numbering for the remainder of the dissertation.

%\newif\if@resttwoside
\newenvironment{ucfrontmatter}{
  \renewcommand{\thepage}{\roman{page}}
  \pagestyle{plain}}
  {\newpage\renewcommand{\thepage}{\arabic{page}}\setcounter{page}{1}}

%%% UCD TITLE PAGE %%%%
%%%%%%%%%%%%%%%%%%%
\def\maketitle{
{ \smallssp
  \let\footnotesize\small \let\footnoterule\relax
  % \thispagestyle{empty}
  \setcounter{page}{1}
  % Davis needs a page number on the first page
  \renewcommand{\thepage}{\roman{page}}% Roman numerals for page counter
  % \null\vfil
  
  \begin{center}
    \fmfont {\bfseries\large {\@title} \par}   % Formatting of the Dissertation title
    \smallskip \vspace{2ex}
    By \par
    \medskip \MakeUppercase{\@author} \par
    \vspace*{\fill}
    \MakeUppercase{\@report} \par
    \smallskip
    \vspace*{\fill}
    \smallskip
    Submitted in partial satisfaction of the requirements for the degree of \par
    \smallskip
    \vspace*{\fill}
    \smallskip
    {\expandafter\uppercase\expandafter{\@degree}} \par
    \vspace*{\fill} 
    \small in \par
    \vspace*{\fill} 
    {\@field}\par
    \vspace*{\fill} 
    \small in the \par
    \vspace*{\fill} 
    \MakeUppercase{OFFICE OF GRADUATE STUDIES} \par
    of the \par
    \MakeUppercase{UNIVERSITY OF CALIFORNIA} \\
    \MakeUppercase{\@campus} \par
    \bigskip \par
    Approved: \par
    \medskip \par
    \bigskip \par
    $\:\overline{~~~~ \mbox{\rule{0in}{0.05in} \hspace{3.25in}}}\:$ \\
    {(\@chair)}, Chair \\
    \vskip 2em
    $\:\overline{~~~~ \mbox{\rule{0in}{0.05in} \hspace{3.25in}}}\:$ \\
    {(\@othermemberA}) \\ 
    \vskip 2em
    $\:\overline{~~~~ \mbox{\rule{0in}{0.05in} \hspace{3.25in}}}\:$ \\
    {(\@othermemberB}) \\
    \vskip 2em
    % add additional members as needed
    Committee in Charge \par
    \@degreeyear
    \end{center}
    }
}


% APPROVALPAGE
%
% The \approvalpage macro emits a UC-approved approval page ready for
% your committee's signature.  The number of committee members,
% affects both the number of lines and the amount of space between lines
% on the approval page.
\def\@numberofmembers{3}
\def\@approvalspace{.75in}
\def\@approvaladjust{-1\@ptsize pt}
\def\numberofmembers#1{\gdef\@numberofmembers{#1}
\ifnum \@numberofmembers > 3
\gdef\@approvalspace{.5in}
\def\@approvaladjust{-1\@ptsize pt}
\fi}

\def\approvalpage{
  \newpage
  % \thispagestyle{empty}
  \renewcommand{\thepage}{\roman{page}}% Davis requires number on every page
  \null\vfill
  \begin{center}
    {\fmfont The Dissertation of {\@author} is approved.} \\

    \vspace{.25in} \vspace{\@approvalspace}
    $\:\overline{~~~~ \mbox{\rule{0in}{0.16in} \hspace{3.5in}}}\:$ \\
    \vspace{\@approvaladjust} {\@othermemberA} \\

    \vspace{\@approvalspace}
    $\:\overline{~~~~ \mbox{\rule{0in}{0.16in} \hspace{3.5in}}}\:$ \\
    \vspace{\@approvaladjust} {\@othermemberB} \\

    \vspace{\@approvalspace}
    \ifnum \@numberofmembers > 3
      $\:\overline{~~~~ \mbox{\rule{0in}{0.16in} \hspace{3.5in}}}\:$ \\
      \vspace{\@approvaladjust} {\@othermemberC} \\
      \vspace{\@approvalspace}
    \fi

    \ifnum \@numberofmembers > 4
      $\:\overline{~~~~ \mbox{\rule{0in}{0.16in} \hspace{3.5in}}}\:$ \\
      \vspace{\@approvaladjust} {\@othermemberD} \\
      \vspace{\@approvalspace}
    \fi

    \ifnum \@numberofmembers > 5
      $\:\overline{~~~~ \mbox{\rule{0in}{0.16in} \hspace{3.5in}}}\:$ \\
      \vspace{\@approvaladjust} {\@othermembers} \\
      \vspace{\@approvalspace}
    \fi

    $\:\overline{~~~~ \mbox{\rule{0in}{0.16in} \hspace{3.15in}}}\:$ \\
    \vspace{\@approvaladjust} {\@chair}, Committee Chair \\
    \vspace{\@approvalspace}
    \vspace{-.25in}
    \vspace{\@approvalspace}
    {\fmfont \@degreemonth~\@degreeyear}
  \end{center}
  \vfill\null
}

% COPYRIGHTPAGE
%
% While it's technically optional, you probably want a copyright page.
% This is a macro, not an environment, because it can be generated
% with the \title, \author, and \year macros.

\def\copyrightpage{
  \if@openright\cleardoublepage\else\clearpage\fi
  \begin{center}
      {\fmfont {\@title} \par
      \vspace{1in}  Copyright \copyright ~\@degreeyear\par
      \vspace{.1in} by\par
      \vspace{.1in} \@author}
  \end{center}
       \if@openright\cleardoublepage \else\clearpage \fi
}

% DEDICATION
\newenvironment{dedication}{
  \if@openright\cleardoublepage \else\clearpage \fi
}{}

% ACKNOWLEDGEMENTS
\newenvironment{acknowledgements}{
  \if@openright\cleardoublepage \else\clearpage \fi
  \begin{center} {\large \bfseries \acknowledgename}
  \end{center}
  \ifnum \@draftmark = 1    \ssp \else  \dsp \fi
}{}

% DISCLAIMER
\newenvironment{disclaimer}{
  \if@openright\cleardoublepage \else\clearpage \fi
  \begin{center} {\large \bfseries \disclaimername}
  \end{center}
  \ifnum \@draftmark = 1    \ssp \else  \dsp \fi
}{}

% VITAE
\newenvironment{vitae}{
  \if@openright\cleardoublepage \else\clearpage \fi
  \ssp
  \begin{center}
    {\large \bfseries \vitaename} \par
    {\large \@author}
  \end{center}
  \begin{list}{}{\leftmargin 0in \itemsep .2in}
  }{\end{list}
}{\par\vfil\null}
\newcommand{\vitaelabels}[1]{#1 \hfil}
\newenvironment{vitaesection}[1]{
  \item {\bf #1}
  \begin{list}{}{\leftmargin 1.5in \labelwidth 1.3in \labelsep .2in
  \parsep 0in
  \let\makelabel\vitaelabels}}{\end{list}}

% UCD ABSTRACT
% The ABSTRACT environment allows for multi-page abstracts and needs the
% \title and \author macros
\def\abstract{
    \if@openright\cleardoublepage \else\clearpage \fi
    \begin{flushright}
    {
        \ssp
        \@author\\
        \@degreemonth\ \@degreeyear\\
        \@field\\
      }
    \end{flushright}
    \begin{center}
      {\fmfont {\bfseries \abstractname}\par}
    \end{center}
    \ifnum \@draftmark = 1  \ssp \else  \dsp \fi
}{\par\vfil\null}


%    ****************************************
%    *             MAIN  MATTER             *
%    ****************************************
%

% MAINMATTER environment
%
% The MAINMATTER environment makes sure that for two side printing,
% the chapters start at odd pages, sets the pagenumbering and pagestyles
%

\newenvironment{ucmainmatter}{%
    \if@openright\cleardoublepage \else\clearpage \fi
    \ifnum \@draftmark = 1  \ssp \else  \dsp \fi
    \pagestyle{headings}
    \setcounter{page}{1}
    \pagenumbering{arabic}
}

%    ****************************************
%    *                LISTS                 *
%    ****************************************
%

\if@twocolumn
  \setlength\leftmargini  {2em}
\else
  \setlength\leftmargini  {2.5em}
\fi
\leftmargin  \leftmargini
\setlength\leftmarginii  {2.2em}
\setlength\leftmarginiii {1.87em}
\setlength\leftmarginiv  {1.7em}
\if@twocolumn
  \setlength\leftmarginv  {.5em}
  \setlength\leftmarginvi {.5em}
\else
  \setlength\leftmarginv  {1em}
  \setlength\leftmarginvi {1em}
\fi
\setlength  \labelsep  {.5em}
\setlength  \labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}
\@beginparpenalty -\@lowpenalty
\@endparpenalty   -\@lowpenalty
\@itempenalty     -\@lowpenalty
\renewcommand\theenumi{\@arabic\c@enumi}
\renewcommand\theenumii{\@alph\c@enumii}
\renewcommand\theenumiii{\@roman\c@enumiii}
\renewcommand\theenumiv{\@Alph\c@enumiv}
\renewcommand\p@enumii{\theenumi}
\renewcommand\p@enumiii{\theenumi(\theenumii)}
\renewcommand\p@enumiv{\p@enumiii\theenumiii}
%\newcommand\labelitemi{\textbullet}
%\newcommand\labelitemii{\normalfont\bfseries \textendash}
%\newcommand\labelitemiii{\textasteriskcentered}
%\newcommand\labelitemiv{\textperiodcentered}
%
% % DESCRIPTION, VERSE, QUOTE & QUOTATION
% % \newenvironment{description}
% %                {\list{}{\labelwidth\z@ \itemindent-\leftmargin
% %                         \let\makelabel\descriptionlabel}}
% %                {\endlist}
% % \newcommand*\descriptionlabel[1]{\hspace\labelsep
% %                                 \normalfont\bfseries #1}
% \newenvironment{verse}
%                {\let\\\@centercr
%                 \list{}{\itemsep      \z@
%                         \itemindent   -1.5em%
%                         \listparindent\itemindent
%                         \rightmargin  \leftmargin
%                         \advance\leftmargin 1.5em}%
%                 \item\relax}
%                {\endlist}
% \newenvironment{quotation}
%                {\list{}{\listparindent 1.5em%
%                         \itemindent    \listparindent
%                         \rightmargin   \leftmargin
%                         \parsep        \z@ \@plus\p@}%
%                 \item\relax}
%                {\endlist}
% \newenvironment{quote}
%                {\list{}{\rightmargin\leftmargin}%
%                 \item\relax}
%                {\endlist}
%
%
% % VERBATIM
% \def\@verbatim{\trivlist\ssp \item[]\if@minipage\else\vskip\parskip\fi
% \leftskip\@totalleftmargin\rightskip\z@
% \parindent\z@\parfillskip\@flushglue\parskip\z@
% \@@par
% \@tempswafalse \def\par{\if@tempswa\hbox{}\fi\@tempswatrue\@@par
% \penalty\interlinepenalty}%
% \obeylines \ttfamily \catcode``=13 \@noligs \let\do\@makeother \dospecials}

% ARRAY AND TABULAR
%

\arraycolsep 5pt     % Half the space between columns in an array
                     % environment.
\tabcolsep 6pt       % Half the space between columns in a tabular
                     % environment.
\arrayrulewidth .4pt % Width of rules in array and tabular environment.
\doublerulesep 2pt   % Space between adjacent rules in array or tabular
                     % environment.

% We have to redefine array here in order to make it single-spaced.
% (Not sure if this is really necessary.)
\def\array{\let\@acol\@arrayacol \let\@classz\@arrayclassz
 \let\@classiv\@arrayclassiv \let\\\@arraycr\let\@halignto\@empty\@tabarray}

% TABBING
%
\tabbingsep \labelsep   % Space used by the \' command.
                        %  (See LaTeX manual.)

% We have to redefine tabular here in order to make it single-spaced.
\def\tabular{\par\ssp\let\@halignto\@empty\@tabular}
\expandafter \def\csname tabular*\endcsname #1%
{\par\ssp\def\@halignto{to#1}\@tabular}

% \smalltabular and \smalltabular* are alternative tabular styles
% in the \small font.  They are required because single-spacing implies a
% change of font to a particular size.
% EVM, 7/20/93
\def\smalltabular{\par\smallssp\let\@halignto\@empty\@tabular}
\def\endsmalltabular{\endtabular}
\expandafter \def\csname smalltabular*\endcsname #1%
{\par\smallssp\def\@halignto{to#1}\@tabular}
\expandafter \let \csname endsmalltabular*\endcsname = \endtabular

% \scriptsizetabular and \scriptsizetabular* are analogs of \smalltabular
\def\scriptsizetabular{\par\scriptsizessp\let\@halignto\@empty\@tabular}
\def\endscriptsizetabular{\endtabular}
\expandafter \def\csname scriptsizetabular*\endcsname #1%
{\par\scriptsizessp\def\@halignto{to#1}\@tabular}
\expandafter \let \csname endscriptsizetabular*\endcsname = \endtabular

% MINIPAGE
%  \@minipagerestore is called upon entry to a minipage environment to
%  set up things that are to be handled differently inside a minipage
%  environment. In the current styles, it does nothing.
%
% \skip\@mpfootins : plays same role for footnotes in a minipage as
%                    \skip\footins does for ordinary footnotes

\skip\@mpfootins = \skip\footins

% FRAMEBOX
%
\fboxsep = 3pt    % Space left between box and text by \fbox and
                  % \framebox.
\fboxrule = .4pt  % Width of rules in box made by \fbox and \framebox.


%    ****************************************
%    *        CHAPTERS AND SECTIONS         *
%    ****************************************
%
% DEFINE COUNTERS:
%
% \newcounter{NEWCTR}[OLDCTR] : Defines NEWCTR to be a counter, which is
%                               reset to zero when counter OLDCTR is
%                               stepped.
%                               Counter OLDCTR must already be defined.

% Must redefine chapter so that we always get a 'completely' blank page in twosideprinting.
\renewcommand\chapter{\if@openright\cleardoublepage\else\clearpage\fi
                    \thispagestyle{plain}%
                    \global\@topnum\z@
                    \@afterindentfalse
                    \secdef\@chapter\@schapter}

% Must redefine @startsection so that we always get indentation.
\def\@startsection#1#2#3#4#5#6{\if@noskipsec \leavevmode \fi
   \par \@tempskipa #4\relax
   \@afterindenttrue
   \ifdim \@tempskipa <\z@ \@tempskipa -\@tempskipa \relax\fi
   \if@nobreak \everypar{}\else
     \addpenalty{\@secpenalty}\addvspace{\@tempskipa}\fi \@ifstar
     {\@ssect{#3}{#4}{#5}{#6}}{\@dblarg{\@sect{#1}{#2}{#3}{#4}{#5}{#6}}}}

%% Redefine @sect so that the abbreviated name is used only for %%
%% the page heading, and the full name goes into the table of   %%
%% contents -- JTW                                              %%

\def\@sect#1#2#3#4#5#6[#7]#8{\ifnum #2>\c@secnumdepth
     \let\@svsec\@empty\else
     \refstepcounter{#1}%
     \let\@@protect\protect
     \def\protect{\noexpand\protect\noexpand}%
     \edef\@svsec{\@seccntformat{#1}}%
     \let\protect\@@protect\fi
     \@tempskipa #5\relax
      \ifdim \@tempskipa>\z@
        \begingroup #6\relax
          \@hangfrom{\hskip #3\relax\@svsec}%
                    {\interlinepenalty \@M #8\par}%
        \endgroup
       \csname #1mark\endcsname{#7}\addcontentsline
         {toc}{#1}{\ifnum #2>\c@secnumdepth \else
                      \protect\numberline{\csname the#1\endcsname}\fi
%%                     #7}\else
                    #8}\else
        \def\@svsechd{#6\hskip #3\relax  %% \relax added 2 May 90
                   \@svsec #8\csname #1mark\endcsname
                      {#7}\addcontentsline
                           {toc}{#1}{\ifnum #2>\c@secnumdepth \else
                           \protect\numberline{\csname the#1\endcsname}%
                                     \fi
%%                        #7}}\fi
                       #8}}\fi
     \@xsect{#5}}


\def\textpages{% Start of text pages
     \advance\textheight by\footskip % has to be done before the clearpage
   \clearpage
   \pagestyle{empty}
   \cleardoublepage
   \pagestyle{myheadings}\markboth{}{}
   \def\@chapapp{\protect\@textofChapter}
   \def\Thechapter{\arabic{chapter}}
   \pagenumbering{arabic}
     \footskip\z@
   }

\def\thepart          {\Roman{part}}
\def\thechapter       {\arabic{chapter}}
\def\thesection       {\thechapter.\arabic{section}}
\def\thesubsection    {\thesection.\arabic{subsection}}
\def\thesubsubsection {\thesubsection .\arabic{subsubsection}}
\def\theparagraph     {\thesubsubsection.\arabic{paragraph}}
\def\thesubparagraph  {\theparagraph.\arabic{subparagraph}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        PART                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


\def\part{\cleardoublepage   % Starts new page.
   \thispagestyle{plain}%    % Page style of part page is 'plain'
   \if@twocolumn             % IF two-column style
     \onecolumn              %  THEN \onecolumn
     \@tempswatrue           %       @tempswa := true
  \else
  \@tempswafalse             %  ELSE @tempswa := false
  \fi                        % FI
  \hbox{}\vfil               % Add fil glue to center title
%%  \bgroup  \centering      % BEGIN centering %% Removed 19 Jan 88
  \secdef\@part\@spart}

\def\@part[#1]#2{\ifnum \c@secnumdepth >-2\relax  % IF secnumdepth > -2
        \refstepcounter{part}%                    %   THEN step
                                                  %         part counter
        \addcontentsline{toc}{part}{\partname~\thepart      %        add toc line
        \hspace{1em}#1}\else                      %   ELSE add
                                                  %         unnumb. line
        \addcontentsline{toc}{part}{#1}\fi        % FI
   \markboth{}{}%
   {\centering                       % %% added 19 Jan 88
    \interlinepenalty \@M            %% RmS added 11 Nov 91
    \ifnum \c@secnumdepth >-2\relax  % IF secnumdepth > -2
      \huge\bfseries \partname~\thepart    %   THEN Print '\partname' and
    \par                             %         number in \huge bold.
    \vskip 20\p@\fi                  %        Add space before title.
    \Huge \bfseries                        % FI
    #2\par}\@endpart}                % Print Title in \Huge bold.
                                     % Bug Fix 13 Nov 89: #1 -> #2

\def\@endpart{\vfil\newpage \if@twoside \hbox{} \thispagestyle{empty}
\newpage
\fi \if@tempswa \twocolumn \fi}

%    ****************************************
%    *         TABLE OF CONTENTS, ETC.      *
%    ****************************************

\def\@pnumwidth{1.55em}
\def\@tocrmarg {2.55em}
\def\@dotsep{4.5}
\setcounter{tocdepth}{1}


% TABLEOFCONTENTS
%  In ucthesis style, \tableofcontents, \listoffigures, etc. are always
%  set in single-column style.  @restonecol

\def\tableofcontents{\@restonecolfalse
  \if@twocolumn\@restonecoltrue\onecolumn\fi
  \chapter*{\contentsname
        \@mkboth{\uppercase{\contentsname}}{\uppercase{\contentsname}}}%
  {\ssp\@starttoc{toc}}\if@restonecol\twocolumn\fi}

\def\l@part#1#2{\addpenalty{-\@highpenalty}%
   \addvspace{2.25em plus\p@}% space above part line
   \begingroup
   \@tempdima 3em         % width of box holding part number, used by
     \parindent \z@ \rightskip \@pnumwidth             %% \numberline
     \parfillskip -\@pnumwidth
     {\large \bfseries          % set line in \large boldface
     \leavevmode          % TeX command to enter horizontal mode.
     #1\hfil \hbox to\@pnumwidth{\hss #2}}\par
     \nobreak             % Never break after part entry
    \global\@nobreaktrue                        %% Added 24 May 89 as
    \everypar{\global\@nobreakfalse\everypar{}}%% suggested by
                                               %% Jerry Leichter
   \endgroup}

%% First line of l@chapter changed 24 May 89, as suggested
%% by Jerry Leichter.
%%
\def\l@chapter#1#2{\addpenalty{-\@highpenalty}%
   \vskip 1.0em plus\p@   % space above chapter line
   \@tempdima 1.5em       % width of box holding chapter number
   \begingroup
     \parindent \z@ \rightskip \@pnumwidth
     \parfillskip -\@pnumwidth
     \bfseries                  % Boldface.
     \leavevmode          % TeX command to enter horizontal mode.
      \advance\leftskip\@tempdima  %% added 5 Feb 88 to conform to
      \hskip -\leftskip            %% 25 Jan 88 change to \numberline
     #1\nobreak\hfil \nobreak\hbox to\@pnumwidth{\hss #2}\par
     \penalty\@highpenalty %% added 24 May 89, suggested by J. Leichter
   \endgroup}

\def\l@section{\@dottedtocline{1}{1.5em}{2.3em}}
\def\l@subsection{\@dottedtocline{2}{3.8em}{3.2em}}
\def\l@subsubsection{\@dottedtocline{3}{7.0em}{4.1em}}
\def\l@paragraph{\@dottedtocline{4}{10em}{5em}}
\def\l@subparagraph{\@dottedtocline{5}{12em}{6em}}

% LIST OF FIGURES
%
% Single-space list of figures, add it to the table of contents.
\def\listoffigures{\@restonecolfalse
  \if@twocolumn\@restonecoltrue\onecolumn\fi
  \chapter*{\listfigurename\@mkboth{\uppercase{\listfigurename}}%
  {\uppercase{\listfigurename}}}
   \addcontentsline{toc}{chapter}{\listfigurename}
   {\ssp\@starttoc{lof}}\if@restonecol
    \twocolumn\fi}

\def\l@figure{\@dottedtocline{1}{1.5em}{2.3em}}

% LIST OF TABLES
%
\def\listoftables{\@restonecolfalse
  \if@twocolumn\@restonecoltrue\onecolumn\fi
  \chapter*{\listtablename\@mkboth{\uppercase{\listtablename}}%
   {\uppercase{\listtablename}}}\@starttoc{lot}\if@restonecol
  \twocolumn\fi}
\def\listoftables{\@restonecolfalse
  \if@twocolumn\@restonecoltrue\onecolumn\fi
  \chapter*{\listtablename\@mkboth{\uppercase{\listtablename}}%
{\uppercase{\listtablename}}}
   \addcontentsline{toc}{chapter}{\listtablename}
   {\ssp\@starttoc{lot}}\if@restonecol
  \twocolumn\fi}

\let\l@table\l@figure


%    ****************************************
%    *           INITIALIZATION             *
%    ****************************************
%
% Default initializations

\ps@plain                   % plain page style
\pagenumbering{arabic}      % Arabic page numbers
\if@twoside\else\raggedbottom\fi % Ragged bottom unless twoside
\ifnum \@draftmark = 1  \ssp \else  \dsp \fi

%\setlength\lineskip{1\p@}
\setlength\lineskip{0.8\p@}
\setlength\parindent{0.25in}
\setlength\paperheight {11in}%
\setlength\paperwidth  {8.5in}

% change sizes and margins
\topmargin      0.25in
\oddsidemargin  0.5in
\evensidemargin 0.25in
\textheight     7.75in % can adjust to 7.00
\textwidth      5.75in
\headsep        25pt
\headheight     12pt
\marginparsep  12pt
\marginparwidth    54pt
\footskip      0.5in % can adjust to 0.1

\endinput
