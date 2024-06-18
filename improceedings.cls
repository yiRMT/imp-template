%%
%% This is file `improceedings.cls'.
%%
%% Ths file is based on the NLProceedings document class under [the MIT License](https://raw.githubusercontent.com/anlp-nenji/nlproceedings/main/LICENSE)
%%

%% Note: このファイルは日本語文字を含みます.

%% 依存パッケージ
\RequirePackage{
  expl3,
  xparse,
  l3keys2e
}

%% クラス宣言
\NeedsTeXFormat{LaTeX2e}
\ProvidesExplPackage {improceedings} {2024-06-01} {1.0.0}
  {Japanese document class for the proceedings of IMP}

%% メッセージ
\msg_new:nnn { improceedings } { disallowed-option }
  { Option~ '#1'~ is~ disallowed;~ skipping. }

%% (u)pTeX 用パッチ類
\clist_const:Nn \c__impr_ptex_requirements_clist { plautopatch }
\sys_if_engine_ptex:T
  {
    \RequirePackage { \c__impr_ptex_requirements_clist }
  }
\sys_if_engine_uptex:T
  {
    \RequirePackage { \c__impr_ptex_requirements_clist }
  }

%% クラスオプション
\bool_new:N \g_impr_english_bool
\bool_new:N \g_impr_presentation_bool

\clist_new:N \g__impr_options_clist
\clist_new:N \g__impr_disallowed_options_clist
\seq_new:N \g__impr_disallowed_options_seq

% jlreq に渡す
\clist_gset:Nn \g__impr_disallowed_options_clist
  {
    article, report, book, paper, fontsize, jafontsize, jafontscale,
    line_length, number_of_lines, head_space, foot_space, gutter, fore_edge,
    fore-edge, headfoot_verticalposition, headfoot_sidemargin, column_gap,
    baselineskip, linegap, hanging_punctuation, narrow_kanjiskip,
    sidenote_length, use_reverse_pagination, landscape, tate, oneside, twoside,
    onecolumn, twocolumn, titlepage, notitlepage, openright, openany
  }
\clist_map_inline:Nn \g__impr_disallowed_options_clist
  {
    \seq_gput_right:Nx \g__impr_disallowed_options_seq { \tl_to_str:n {#1} }
  }
\cs_new:Nn \__impr_process_class_option:
  {
    % 2020年に変更 \l_keys_key_tl -> \l_keys_key_str
    \cs_if_exist:NF \l_keys_key_str
      { \cs_set_eq:NN \l_keys_key_str \l_keys_key_tl }
    \seq_if_in:NoTF \g__impr_disallowed_options_seq { \l_keys_key_str }
      { \msg_warning:nnx { improceedings } { disallowed-option } { \l_keys_key_str } }
      { \clist_gput_right:No \g__impr_options_clist { \CurrentOption } }
  }

% オプション実行
\keys_define:nn { improceedings / option }
  {
    english .bool_gset:N = \g_impr_english_bool,
    english .default:n = true,
    presentation .bool_gset:N = \g_impr_presentation_bool,
    presentation .default:n = true,
    meeting .bool_gset_inverse:N = \g_impr_presentation_bool,
    meeting .default:n = true,
    unknown .code:n = \__impr_process_class_option:
  }
\ProcessKeysOptions { improceedings / option }
\PassOptionsToClass { \g__impr_options_clist } { jlreq }


%% 基本版面設計
% 規定オプションを指定して jlreq を読み込む
\LoadClass
  [
    paper=a4,            % 用紙サイズ
    \bool_if:NTF \g_impr_presentation_bool { twocolumn } { onecolumn }, % 1段組/2段組
    fontsize=10pt,       % フォントサイズ
    % 日本語と英語で行間を調整
    \bool_if:NT \g_impr_english_bool { linegap=0.6\baselineskip },
    head_space=2cm,      % 天
    foot_space=3cm,      % 地
    gutter=2cm,          % のど
    fore-edge=2cm,       % 小口
  ] { jlreq }

% 装飾用
\RequirePackage{graphicx,xcolor}
\RequirePackage{url}
\RequirePackage{hyperref}
\RequirePackage{cite}

% 擬似コード
\RequirePackage{algpseudocode, algorithm}

% 数式
\RequirePackage{amsmath}

% If LuaTeX is used, load luatexja-preset
% else, load otf package

\sys_if_engine_luatex:T
  {
    \RequirePackage[haranoaji]{luatexja-preset}
  }
\sys_if_engine_luatex:F
  {
    \RequirePackage{otf}
  }

% 欧文フォント
\RequirePackage[T1]{fontenc}
\RequirePackage[full]{textcomp}               % 記号類の補完
\RequirePackage{newtxtext}       % 脚注記号は LaTeX 標準のまま
\RequirePackage[bigdelims]{newtxmath}                    % 数式
\RequirePackage[cal=boondoxo]{mathalfa}       % 花文字

%% タイトル
\def\term#1{\def\@term{#1}}\term{}            % 期間
\def\group#1{\def\@group{#1}}\group{}         % 研究班
\def\grade#1{\def\@grade{#1}}\grade{}         % 学年
\def\zenki{前期研究発表資料}
\def\kouki{後期研究発表資料}
\def\jkjikken#1{情報工学実験I\hspace{-.1em}I 発表資料 #1}

\group_begin:
\makeatletter
\gdef\@maketitle{%
  \newpage\null
  \begin{center}%
    \let\footnote\thanks
    {\LARGE
      {\normalsize
        \bool_if:NTF \g_impr_presentation_bool { \@term\hskip.5em\@date } { \@date }
        \hfill
        \@group\hskip.5em\@grade\hskip.5em\@author
      }
      \par
      \vspace{-5truemm}
      \hrulefill
      \vspace{-1truemm}
      \par
      \gtfamily\bfseries\@title
      \par
      \vspace{-5truemm}
      \hrulefill
      \par
    }%
  \end{center}%
  \par
  \vskip\baselineskip
  \ifvoid\jlreq@abstractbox\else\centerline{\box\jlreq@abstractbox}\vskip1.5em\fi
}
\group_end:

%% 英語対応
\bool_if:NT \g_impr_english_bool
  {
    \tl_set:Nn \abstractname { Abstract }
    \tl_set:Nn \contentsname { Table~ of~ Contents }
    \tl_set:Nn \refname { References }
    \tl_set:Nn \indexname { Index }
    \tl_set:Nn \listfigurename { List~ of~ Figures}
    \tl_set:Nn \figurename { Figure }
    \tl_set:Nn \listtablename { List~ of~ Tables }
    \tl_set:Nn \tablename { Table }
    \tl_set:cn { fnum@figure } { \figurename\nobreakspace\thefigure }
    \tl_set:cn { fnum@table } { \tablename\nobreakspace\thetable }
    \RequirePackage[yyyymmdd]{datetime}
    \renewcommand{\dateseparator}{/}
  }

%% 見出し
\ModifyHeading{section}{
  lines=2,
}

%% 参考文献
\renewenvironment{thebibliography}[1]{%
  \jlreq@oldfontcommand@enable
  \section*{\refname}%
  \@mkboth{\refname}{\refname}%
  \bibfont
  \list{\@biblabel{\@arabic\c@enumiv}}%
      {\settowidth\labelwidth{\@biblabel{#1}}%
      \labelsep=1\zw
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemindent=0pt
      \@openbib@code
      \usecounter{enumiv}%
      \let\p@enumiv\@empty
      \renewcommand\theenumiv{\@arabic\c@enumiv}}%
  \sloppy
  \clubpenalty4000
  \@clubpenalty\clubpenalty
  \widowpenalty4000%
  \sfcode`\.\@m
}{%
  \def\@noitemerr{\@latex@warning{Empty `thebibliography' environment}}%
  \endlist
  \jlreq@oldfontcommand@disable
}
\tl_set:Nn \bibfont { \small }

%% 各種寸法
\AtBeginDocument{
  \setlength{\abovedisplayskip}{6pt plus 3pt minus 3pt}
  \setlength{\belowdisplayskip}{6pt plus 3pt minus 3pt}
  \setlength{\floatsep}{6pt plus 2pt minus 2pt}
  \setlength{\textfloatsep}{10pt plus 2pt minus 4pt}
  \setlength{\intextsep}{6pt plus 2pt minus 2pt}
  \setlength{\dblfloatsep}{6pt plus 2pt minus 2pt}
  \setlength{\dbltextfloatsep}{10pt plus 2pt minus 4pt}
  \setlength{\abovecaptionskip}{.25\baselineskip}
  \setlength{\belowcaptionskip}{0pt}
}
\jlreqsetup{
  itemization_beforeafter_space={0pt,i=.25\baselineskip},
  caption_font={\small},  % キャプション
}
\ModifyHeading{section}{
  font={\Large\bfseries},
}
\ModifyHeading{subsection}{
  font={\large\bfseries},
}
\ModifyHeading{subsubsection}{
  font={\normalsize\bfseries},
}

% vim: ft=expl3 nospell:
%% EOF