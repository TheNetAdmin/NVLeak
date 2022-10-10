\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{paper}

\usepackage{ifthen}

%==================%
% Conf templates   %
%==================%

\newcommand{\confasplos}
{
    % ASPLOS Style
    \LoadClass[pageno]{config/asplos/jpaper}
    \newcommand{\asplossubmissionnumber}{XXX}

    \usepackage[normalem]{ulem}

    % Bib
    \newcommand{\napaperbib}{
        \bibliographystyle{plain}
        \bibliography{content/ref.bib}
    }
    % Page style
    \newcommand{\napaperpagestyle}{
        \thispagestyle{empty}
    }
}
\newcommand{\confisca}
{
    % ISCA Style
    \LoadClass[conference]{config/isca/IEEEtran}

    % From ISCA 2020 Template
    \usepackage{cite}
    \usepackage{amsmath,amssymb,amsfonts}
    % \usepackage{algorithmic}
    \usepackage{graphicx}
    \usepackage{textcomp}
    \usepackage{xcolor}
    \usepackage{fancyhdr}
    \usepackage[hyphens]{url}

\def\BibTeX{{\rm B\kern-.05em{\sc i\kern-.025em b}\kern-.08em
    T\kern-.1667em\lower.7ex\hbox{E}\kern-.125emX}}

    % Ensure letter paper
    \pdfpagewidth=8.5in
    \pdfpageheight=11in


    %%%%%%%%%%%---SETME-----%%%%%%%%%%%%%
    \newcommand{\iscasubmissionnumber}{XXX}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    \fancypagestyle{firstpage}{
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \fancyhead[C]{\normalsize{ISCA 2020 Submission
        \textbf{\#\iscasubmissionnumber} \\ Confidential Draft: DO NOT DISTRIBUTE}}
    \fancyfoot[C]{\thepage}
    }

    \pagenumbering{arabic}
    % Bib
    \newcommand{\napaperbib}{
        \bibliographystyle{IEEEtranS}
        \bibliography{content/ref.bib}
    }
    % Page style
    \newcommand{\napaperpagestyle}{
        \thispagestyle{firstpage}
        \pagestyle{plain}
    }
}
\newcommand{\confmicro}
{
    % % Micro 2020 Style
    \LoadClass{config/micro/sig-alternate}
    \usepackage{mathptmx} % This is Times font

    \usepackage{fancyhdr}
    \usepackage[normalem]{ulem}
    \usepackage[hyphens]{url}
    \usepackage[sort,nocompress]{cite}
    \usepackage[final]{microtype}
    \usepackage[keeplastbox]{flushend}
    % Always include hyperref last
    \usepackage[bookmarks=true,breaklinks=true,letterpaper=true,colorlinks,linkcolor=black,citecolor=blue,urlcolor=black]{hyperref}

    % Ensure letter paper
    \pdfpagewidth=8.5in
    \pdfpageheight=11in

    %%%%%%%%%%%---SETME-----%%%%%%%%%%%%%
    \newcommand{\microsubmissionnumber}{XXX}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    \fancypagestyle{firstpage}{
      \fancyhf{}
      \renewcommand{\headrulewidth}{0pt}
      \fancyhead[C]{\vspace{15pt}\normalsize{MICRO 2020 Submission
          \textbf{\#\microsubmissionnumber} -- Confidential Draft -- Do NOT Distribute!!}}
      \fancyfoot[C]{\thepage}
    }

    \pagenumbering{arabic}

    % Bib
    \newcommand{\napaperbib}{
        \bibliographystyle{IEEEtranS}
        \bibliography{content/ref.bib}
    }
    % Page style
    \newcommand{\napaperpagestyle}{
        \thispagestyle{firstpage}
        \pagestyle{plain}
    }
}
\newcommand{\confieee}
{
    % IEEE conference -- MICRO2020 camera ready
    \LoadClass[conference]{config/ieee/IEEEtran}
    \IEEEoverridecommandlockouts
    % The preceding line is only needed to identify funding in the first footnote. If that is unneeded, please comment it out.
    \usepackage{cite}
    \usepackage{amsmath,amssymb,amsfonts}
    \usepackage{algorithmic}
    \usepackage{graphicx}
    \usepackage{textcomp}
    \usepackage{xcolor}
\def\BibTeX{{\rm B\kern-.05em{\sc i\kern-.025em b}\kern-.08em
    T\kern-.1667em\lower.7ex\hbox{E}\kern-.125emX}}

    % Bib
    \newcommand{\napaperbib}{
        \bibliographystyle{IEEEtranS}
        \bibliography{content/ref.bib}
    }
    % Page style
    \newcommand{\napaperpagestyle}{
        % None specified
    }
}
\newcommand{\confusenix}
{
    % USENIX conference, e.g. ATC
    \LoadClass[letterpaper,twocolumn,10pt]{article}
    \usepackage{config/usenix/usenix-2020-09}
    % Bib
    \newcommand{\napaperbib}{
        \bibliographystyle{plainurl}
        \bibliography{content/ref.bib}
    }
    % Page style
    \newcommand{\napaperpagestyle}{
        \thispagestyle{empty} % Camera ready style
        \pagestyle{empty}     % Camera ready style
    }
}
\newcommand{\confsp}{
    % IEEE S&P
    \LoadClass[conference]{config/ieee/IEEEtran}
    \usepackage{cite}
    \usepackage{amsmath,amssymb,amsfonts}
    \usepackage{algorithmic}
    \usepackage{graphicx}
    \usepackage{textcomp}
    \usepackage[table]{xcolor}
    % Bib
    \newcommand{\napaperbib}{
        \bibliographystyle{IEEEtranS}
        \bibliography{content/ref.bib}
    }
    % Page style
    \newcommand{\napaperpagestyle}{
      \thispagestyle{firstpage}
      \pagestyle{plain}
    }
}
\newcommand{\confeurosys}
{
    \LoadClass[sigplan,review,anonymous]{acmart}
    \acmSubmissionID{XXX}
    \renewcommand\footnotetextcopyrightpermission[1]{}
}

\confusenix{}

%==================%
% General settings %
%==================%

\usepackage{amssymb}
\usepackage{amsfonts}
\usepackage{amsmath}
\usepackage{commath}
\usepackage{float}
\usepackage{pgfplots}
% \usepackage{algorithm}
% \usepackage{algpseudocode}
\usepackage{booktabs}
\usepackage{listings}
\usepackage{times}
\usepackage{comment}
\usepackage{tabularx}
\usepackage{booktabs}
\usepackage{textcomp} % For \textperthousand
\usepackage{multirow}
\usepackage{makecell}
\usepackage[inline]{enumitem}
\usepackage[roman]{parnotes}
% \usepackage{threeparttable}
\usepackage{minted}
\usepackage{xspace}
\usepackage{ctable}
\usepackage[T1]{fontenc}
\usepackage{textcomp}

% https://tex.stackexchange.com/a/349084
% \usepackage{flushend}

\usepackage{inconsolata}

\pgfplotsset{compat=1.15}

\makeatletter
\let\MYcaption\@makecaption
\makeatother
% \usepackage[font=scriptsize]{caption}
\usepackage[font+=smaller,skip=1pt]{subcaption}
\makeatletter
\let\@makecaption\MYcaption
\makeatother

% \setlength{\belowcaptionskip}{-10pt}
% \captionsetup{
%     belowskip=0pt
% }

\lstset{
    frameround=fttt,
    language=C,
    % numbers=left,
    breaklines=true,
    keywordstyle=\color{black}\bfseries,
    basicstyle=\ttfamily\color{black},
    numberstyle=\color{black}
}
\lstMakeShortInline[columns=fixed]|

\graphicspath{{figure/}}

\tikzstyle{every picture}+=[font=\sffamily]

\def\sectionautorefname{\S}
\def\subsectionautorefname{\S}
\def\subsubsectionautorefname{\S}
\def\algorithmautorefname{Algorithm}

\def\secref{\autoref}
\def\figref{\autoref}
\def\tabref{\autoref}
\def\obsref{Observation~\ref}

% For tabularx
\newcolumntype{Q}{>{\raggedleft\arraybackslash}X}
\newcolumntype{P}{X<{\centering}}

\newcommand{\squishlist}{
   \begin{list}{$\bullet$}{%
        \setlength{\itemsep}{0pt}%
        \setlength{\parsep}{0pt}%
        \setlength{\topsep}{-3pt}%
        \setlength{\partopsep}{0pt}%
        \setlength{\listparindent}{-2pt}%
        \setlength{\itemindent}{-5pt}%
        \setlength{\leftmargin}{1em}%
        \setlength{\labelwidth}{0em}%
        \setlength{\labelsep}{0.5em}%
    }
}

\newcommand{\squishend}{
    \end{list}  }

\newenvironment{CompactItemize}%
{\begin{list}{$\bullet$}%
    {\leftmargin=\parindent \itemsep=2pt \topsep=2pt
    \parsep=0pt \partopsep=0pt}}%
{\end{list}}

% \newcommand{\para}[1]{\vspace{3pt}\noindent\textbf{#1}}
\newcommand{\para}[1]{\vspace{0.5ex}\noindent\textbf{{{{#1}}\hspace{0.5em}}}}
\newcommand{\subpara}[1]{\vspace{3pt}\noindent\textit{#1}}

\newcommand*\mycircinternal[1]{%
  \tikz[baseline=(char.base)]{%
  \node[minimum size=0.325cm,shape=circle,draw,inner sep=0.25pt,fill=black,text=white,font=\bfseries] (char) {\small#1};}%
\newcommand*\mycirc[1]{%
\raisebox{.5pt}{\mycircinternal{\raisebox{-.9pt} {#1}}}%
}}

% Check mark and cross mark
% \usepackage{pifont}
% \newcommand{\cmark}{\ding{51}}
% \newcommand{\xmark}{\ding{55}}

% https://tex.stackexchange.com/a/169711
\renewcommand{\floatpagefraction}{.9}

\newboolean{publicversion}
\newboolean{revisedversion}
\newboolean{commentversion}
\setboolean{publicversion}  {true}
\setboolean{revisedversion} {false}
\setboolean{commentversion} {true}

% % Don't use `todonote` package, it slows down the LaTeX compilation
% % Treat todo as text or not
% \ifthenelse{\boolean{todoastext}}{
%     % Output todo as text
%     \newcommand{\todocolortext}[3]{\color{2}#3}
% }{
%     % Assert error at todo
%     \newcommand{\todocolortext}[1]{Do NOT use \\#1 for public version!}
% }

% Paper presentation
\ifthenelse{\boolean{publicversion}}{
    \setboolean{revisedversion}{false}
    \setboolean{commentversion}{false}
}{
    \newcommand{\draftversion}{ConfName}

    % For date time print
    \edef\pdfilemoddate#1{\pdfcreationdate}
    \usepackage[useregional]{datetime2}
    \usepackage{background}
    \backgroundsetup{
        color=gray,
        position=current page.west,
        angle=90,
        nodeanchor=west,
        vshift=-5mm,
        hshift=-20mm,
        opacity=1,
        scale=1.75,
        contents=DRAFT [Ver.{\draftversion}] {\DTMnow} {Page \thepage}
    }
}

% Revision
\ifthenelse{\boolean{revisedversion}}{
    \usepackage{soul, color}

    % Register customized commands to soul, so that \hl and \st can process
    % these commands without compilation errors
    %
    % https://tex.stackexchange.com/a/139500
    % arg#2 available values:
    %   0 or 1: font switching commands
    %        7: \textsuperscript or similar commands, e.g., \cite, \ref
    %        8: \footnote
    %        9: accents

    % Reference style commands
    \soulregister{\cite}    {7}
    \soulregister{\ref}     {7}
    \soulregister{\autoref} {7}
    \soulregister{\figref}  {7}
    \soulregister{\secref}  {7}
    \soulregister{\tabref}  {7}
    \soulregister{\pageref} {7}

    % Font switching style commands
    \soulregister{\para}    {1}
    \soulregister{\zixuan}  {1}

    % % https://tex.stackexchange.com/questions/282386/make-soul-highlight-span-lines
    % \makeatletter
    % \def\SOUL@hlpreamble{%
    %     \setul{\dp\strutbox}{\dimexpr\ht\strutbox+\dp\strutbox\relax}%
    %     \let\SOUL@stcolor\SOUL@hlcolor
    %     \SOUL@stpreamble
    % }
    % \makeatother

    % Usage:
    % \st{for paragraph with deleting lines}.}
    % \hl{highlight a paragraph with yellow background.}
} {
    % \renewcommand{\st}[1]{}
    % \renewcommand{\hl}[1]{}
    \newcommand{\st}[1]{\PackageError{napaper}{Do NOT use \\st for public version!}}
    \newcommand{\hl}[1]{\PackageError{napaper}{Do NOT use \\hl for public version!}}
}

% Comments
\ifthenelse{\boolean{commentversion}}{
    \newcommand{\inlinecomment}[3]{{\color{#1}\sf \footnotesize #2: #3}}
    \newcommand{\ignore}       [1]{{\color{gray}\sf #1}}
    \newcommand{\updatelater}  [1]{{\color{blue}#1}}
}{
    \newcommand{\inlinecomment}[3]{}
    \newcommand{\ignore}[1]{}
    % \newcommand{\updatelater}[1]{#1}
    \newcommand{\updatelater}[1]{\PackageError{napaper}{Do NOT use \\updatelater for public version!}}
}

\newcommand{\zixuan}       [1]{\inlinecomment{brown}  {Zixuan}{#1}}
