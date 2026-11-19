\NeedsTeXFormat{LaTeX2e} % formatted as LaTeX2e
%% 必须要加
\ProvidesClass{UWMadisonHomework}[2024/09/05 UWMadison Homework LaTeX class (copy from SUSTechHomework.cls)]
% 作用：加载并继承另一个类文件的功能。这里加载了 article 类的所有默认设置和结构。
\LoadClass[a4paper]{article} % article：这是一个标准的 LaTeX 类，通常用于撰写学术文章、论文或简单的报告。这条指令加载了 article 类的所有默认设置和结构。

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 加载宏包
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage{newpxtext,newpxmath}
\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{amsmath}
\RequirePackage{listings}
\RequirePackage{xeCJK}
\RequirePackage[T1]{fontenc}
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}
\RequirePackage{booktabs}
\RequirePackage{parskip}
\RequirePackage[hidelinks]{hyperref}
% \RequirePackage{courier}
\RequirePackage{inconsolata}
\RequirePackage{tikz}
\RequirePackage{hyperref}
\RequirePackage{enumitem}  % 控制列表样式
\RequirePackage{tcolorbox}
\RequirePackage{subcaption} % 引入 subcaption 宏包

% \DeclareOption{titlepage}{}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 整体布局设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 页面左右边距为 0.85 英寸，上边距为 1 英寸，下边距为 0.8 英寸，以及装订偏移为 0.15 英寸
\geometry{
    left=.85in,
    right=.85in,
    top=1in,
    bottom=.8in,
    bindingoffset=.15in
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 对标题进行布局设置（需要用到前面定义的宏）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 自定义宏
% 这两段代码定义了一个宏 \sid，并处理了它的默认行为和错误提示
\def\clsID#1{\gdef\@clsID{#1}}
\def\@clsID{\@latex@error{No \noexpand\clsID given}\@ehc}

\def\coursename#1{\gdef\@coursename{#1}}
\def\@coursename{\@latex@error{No \noexpand\coursename given}\@ehc}

\def\coursecode#1{\gdef\@coursecode{#1}}
\def\@coursecode{\@latex@error{No \noexpand\coursecode given}\@ehc}

\def\univ#1{\gdef\@univ{#1}}
\def\@univ{\@latex@error{No \noexpand\univ given}\@ehc}
\univ{UW-Madison}

% 定义新命令 \mktitle, 用于生成标题，包括课程代码、课程名称、作业标题、作者、学号和日期
% 注意与 maketitle 是不同的命令
\newcommand{\mktitle}{
    % 使用了 minipage 环境将页面分成左右两部分，以实现对齐布局
    % \noindent 去掉段落首行缩进，\makebox[\linewidth]{...} 创建一个盒子，它的宽度与当前行的宽度相同
    \noindent\makebox[\linewidth]{
        % 左边的部分 : 创建一个最小页(minipage)，宽度为页面宽度的70% (0.7\linewidth)，内容从底部对齐([b])。
        \begin{minipage}[b]{.7\linewidth}
            % 使用大号无衬线字体显示课程代码 (\@coursecode) 和课程名称 (\@coursename)，用“·”符号分隔。\\\\：这是一个强制换行符，告诉 LaTeX 在这里换行。类似于 \newline，但更常用于特定的表格和排版场景。
            {\Large\textsf{\@coursecode~$\cdot$~\@coursename}}\\\\
            {\Huge\textbf\@title}
        \end{minipage}\hfill

        % 右边的部分
        \begin{minipage}[b]{.3\linewidth}
            % \large\begin{flushright}：使用大号字体，并右对齐以下内容。
            \large\begin{flushright}
                \@author~/~\@clsID\\
                \vspace{.5em}
                \@date
            \end{flushright}
        \end{minipage}
    }
    
    % \noindent 去掉缩进，\rule{\linewidth}{1.5pt} 创建了一条横跨整行的水平线，线宽为1.5pt。
    \noindent\rule{\linewidth}{1.5pt}
    % 检查文档是否是双栏布局，如果是，则添加额外的垂直空间（0.5em）
    \if@twocolumn\vspace{.5em}\fi
    % \thispagestyle{empty}：当前页面不显示页眉或页脚。
    \thispagestyle{empty}
}

\if@twocolumn
	\renewcommand{\maketitle}{\twocolumn[\mktitle]}
\else
	\renewcommand{\maketitle}{\mktitle}
\fi
% 这段代码主要用于使用 fancyhdr 宏包来自定义页眉和页脚的布局和格式
\pagestyle{fancy} % 将整个文档的页眉和页脚样式设置为 fancy
\fancyhf{} % 清除默认的页眉和页脚内容，确保之后你可以自定义自己的页眉和页脚
\renewcommand{\headrulewidth}{0.3pt} % 设置页眉下方的横线（页眉线）的厚度为 0.3pt

\if@twoside
    \fancyhead[EL,OR]{\thepage~/~\pageref{LastPage}}
    \fancyhead[EC]{\textsc{\@coursename}}
    \fancyhead[ER]{\@title}
    \fancyhead[OL]{\@univ~$\circ$~\@coursecode}
    \fancyhead[OC]{\textsc{\@author  $\cdot$ \@clsID}}

    \fancyfoot[EL,OR]{sfang65@wisc.edu}
    \fancyfoot[EC,OC]{}
    \fancyfoot[ER,OL]{}
\else
    \lhead{\textsc{\@author $\cdot$ \@clsID}}
    \chead{\textsc{\@coursename~$\circ$~\@title}}
    \rhead{\thepage~/~\pageref{LastPage}}

    % 设置页脚内容
    \lfoot[L]{sfang65@wisc.edu}   % 页脚左侧
    \cfoot[C]{} % 页脚中间
    \rfoot[R]{}  % 页脚右侧
\fi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 文章排版
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \setlength{\parindent}{0pt} 是 LaTeX 中的一条命令，用于设置段落的首行缩进（indentation）长度为 0pt（0 磅）。这意味着在新的段落中，第一行不会缩进。
% 这段代码使用了 LaTeX 的 listings 宏包来设置代码块的格式
\setlength{\parindent}{0pt}

% 这段代码使用了 LaTeX 的 listings 宏包来设置代码块的格式
\lstset{
    numbers=left, % 在代码块的左侧显示行号
    basicstyle=\ttfamily, % 设置代码块的基本字体样式
    frame=shadowbox, % 在代码块周围加上一个带有阴影的框
    columns=flexible, % 调整代码块中的列对齐方式
    xleftmargin=1.5em, % 设置代码块左边的缩进，左边距为 1.5 倍的字母宽度（em 单位），为代码块增加适当的空白，使其不紧贴页面边缘
    xrightmargin=1em % 设置代码块右边的缩进，右边距为 1 倍的字母宽度（em 单位），为代码块增加适当的空白，使其不紧贴页面边缘
}
