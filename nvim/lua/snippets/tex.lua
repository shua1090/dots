local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta

return {
  -- Documents and structure
  s("doc", fmta([[
\documentclass[11pt]{article}

\usepackage[margin=1in]{geometry}
\usepackage{amsmath, amssymb, amsthm, mathtools}
\usepackage{enumitem}

\newtheorem{theorem}{Theorem}[section]
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{corollary}[theorem]{Corollary}

\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{example}[theorem]{Example}
\theoremstyle{remark}
\newtheorem{remark}[theorem]{Remark}

% Number systems
\newcommand{\N}{\mathbb{N}}
\newcommand{\Z}{\mathbb{Z}}
\newcommand{\Q}{\mathbb{Q}}
\newcommand{\R}{\mathbb{R}}
\newcommand{\C}{\mathbb{C}}
\newcommand{\F}{\mathbb{F}}

% Delimiters
\newcommand{\abs}[1]{\left|#1\right|}
\newcommand{\norm}[1]{\left\|#1\right\|}
\newcommand{\set}[1]{\left\{#1\right\}}
\newcommand{\gen}[1]{\left\langle #1 \right\rangle}

% Algebra operators
\newcommand{\normal}{\trianglelefteq}
\newcommand{\Aut}{\operatorname{Aut}}
\newcommand{\End}{\operatorname{End}}
\newcommand{\Gal}{\operatorname{Gal}}
\newcommand{\Inn}{\operatorname{Inn}}
\newcommand{\Ker}{\operatorname{Ker}}
\newcommand{\im}{\operatorname{im}}
\newcommand{\Ann}{\operatorname{Ann}}
\newcommand{\ord}{\operatorname{ord}}
\newcommand{\sgn}{\operatorname{sgn}}
\newcommand{\Stab}{\operatorname{Stab}}
\newcommand{\Orb}{\operatorname{Orb}}
\newcommand{\id}{\operatorname{id}}
\newcommand{\Frac}{\operatorname{Frac}}

\title{<>}
\author{<>}
\date{<>}

\begin{document}
\maketitle

<>

\end{document}
]], { i(1, "Abstract Algebra Notes"), i(2, "Shynn"), i(3, "\\today"), i(0) })),
  s("sec", fmta("\\section{<>}", { i(1, "Title") })),
  s("ssec", fmta("\\subsection{<>}", { i(1, "Title") })),
  s("sssec", fmta("\\subsubsection{<>}", { i(1, "Title") })),
  s("lbl", fmta("\\label{<>}", { i(1, "label") })),
  s("ref", fmta("\\ref{<>}", { i(1, "label") })),
  s("eqref", fmta("\\eqref{<>}", { i(1, "label") })),
  s("cite", fmta("\\cite{<>}", { i(1, "key") })),
  s("ncmd", fmta("\\newcommand{\\<>}{<>}", { i(1, "name"), i(2, "definition") })),
  s("op", fmta("\\operatorname{<>}", { i(1, "op") })),
  s("txt", fmta("\\text{<>}", { i(1) })),
  s("bf", fmta("\\textbf{<>}", { i(1) })),
  s("em", fmta("\\emph{<>}", { i(1) })),

  -- Environments
  s("thm", fmta([[
\begin{theorem}[<>]
<>
\end{theorem}
]], { i(1, "Name"), i(0) })),
  s("lem", fmta([[
\begin{lemma}[<>]
<>
\end{lemma}
]], { i(1, "Name"), i(0) })),
  s("prop", fmta([[
\begin{proposition}[<>]
<>
\end{proposition}
]], { i(1, "Name"), i(0) })),
  s("cor", fmta([[
\begin{corollary}[<>]
<>
\end{corollary}
]], { i(1, "Name"), i(0) })),
  s("def", fmta([[
\begin{definition}[<>]
<>
\end{definition}
]], { i(1, "Name"), i(0) })),
  s("ex", fmta([[
\begin{example}
<>
\end{example}
]], { i(0) })),
  s("rem", fmta([[
\begin{remark}
<>
\end{remark}
]], { i(0) })),
  s("proof", fmta([[
\begin{proof}
<>
\end{proof}
]], { i(0) })),
  s("qed", t("\\qed")),
  s("pf", fmta("\\textbf{Pf:} <>", { i(0) })),
  s("claim", fmta("\\textbf{Claim:} <>", { i(0) })),
  s("explain", fmta("\\text{ <> }", { i(1) })),
  s("enum", fmta([[
\begin{enumerate}
  \item <>
\end{enumerate}
]], { i(0) })),
  s("item", fmta([[
\begin{itemize}
  \item <>
\end{itemize}
]], { i(0) })),
  s("align", fmta([[
\begin{align*}
  <> &= <>
\end{align*}
]], { i(1, "x"), i(0, "y") })),
  s("align2", fmta([[
\begin{align*}
  <> &= <> \\
  <> &= <>
\end{align*}
]], { i(1, "x"), i(2, "y"), i(3, "x"), i(0, "y - 0") })),
  s("eq", fmta([[
\begin{equation*}
  <>
\end{equation*}
]], { i(0) })),
  s("cases", fmta([[
\begin{cases}
  <>, & <> \\
  <>, & <>
\end{cases}
]], { i(1), i(2), i(3), i(0) })),

  -- Inline and display math
  s("mm", fmta("$<>$", { i(1) })),
  s("dm", fmta([[
\[
  <>
\]
]], { i(1) })),
  s("frac", fmta("\\frac{<>}{<>}", { i(1), i(2) })),
  s("dfrac", fmta("\\dfrac{<>}{<>}", { i(1), i(2) })),
  s("sq", fmta("\\sqrt{<>}", { i(1) })),
  s("sum", fmta("\\sum_{<>}^{<>}", { i(1, "i=1"), i(2, "n") })),
  s("prod", fmta("\\prod_{<>}^{<>}", { i(1, "i=1"), i(2, "n") })),
  s("lim", fmta("\\lim_{<> \\to <>}", { i(1, "n"), i(2, "\\infty") })),
  s("vec", fmta("\\mathbf{<>}", { i(1, "v") })),
  s("inv", fmta("<>^{-1}", { i(1, "g") })),
  s("pow", fmta("<>^{<>}", { i(1, "x"), i(2, "n") })),
  s("idx", fmta("<>_{<>}", { i(1, "a"), i(2, "i") })),
  s("abs", fmta("\\left| <> \\right|", { i(1, "G") })),
  s("norm", fmta("\\left\\| <> \\right\\|", { i(1, "x") })),
  s("paren", fmta("\\left( <> \\right)", { i(1) })),
  s("brak", fmta("\\left[ <> \\right]", { i(1) })),
  s("ceil", fmta("\\left\\lceil <> \\right\\rceil", { i(1) })),
  s("floor", fmta("\\left\\lfloor <> \\right\\rfloor", { i(1) })),
  s("eval", fmta("\\left. <> \\right|_{<>}", { i(1, "f"), i(2, "x=a") })),

  -- Sets and logic
  s("set", fmta("\\{ <> \\}", { i(1, "x") })),
  s("setb", fmta("\\{ <> \\mid <> \\}", { i(1, "x"), i(2, "condition") })),
  s("inn", t("\\in")),
  s("nin", t("\\notin")),
  s("sub", t("\\subseteq")),
  s("psub", t("\\subset")),
  s("nsub", t("\\nsubseteq")),
  s("sup", t("\\supseteq")),
  s("cup", t("\\cup")),
  s("cap", t("\\cap")),
  s("empty", t("\\varnothing")),
  s("comp", fmta("<>^{c}", { i(1, "A") })),
  s("union", fmta("\\bigcup_{<>}", { i(1, "i \\in I") })),
  s("inter", fmta("\\bigcap_{<>}", { i(1, "i \\in I") })),
  s("fa", fmta("\\forall <> \\in <>", { i(1, "x"), i(2, "S") })),
  s("exs", fmta("\\exists <> \\in <>", { i(1, "x"), i(2, "S") })),
  s("imp", t("\\implies")),
  s("iff", t("\\iff")),
  s("land", t("\\land")),
  s("lor", t("\\lor")),
  s("not", t("\\neg")),
  s("neq", t("\\neq")),
  s("le", t("\\leq")),
  s("ge", t("\\geq")),
  s("lt", t("<")),
  s("gt", t(">")),
  s("equiv", fmta("\\equiv <> \\pmod{<>}", { i(1, "a"), i(2, "n") })),
  s("mid", t("\\mid")),
  s("nmid", t("\\nmid")),
  s("pm", t("\\pm")),
  s("mp", t("\\mp")),
  s("dots", t("\\dots")),
  s("cdots", t("\\cdots")),
  s("vdots", t("\\vdots")),
  s("ddots", t("\\ddots")),
  s("there", t("\\therefore")),
  s("because", t("\\because")),

  -- Common number systems and symbols
  s("AA", t("\\mathbb{A}")),
  s("NN", t("\\mathbb{N}")),
  s("ZZ", t("\\mathbb{Z}")),
  s("QQ", t("\\mathbb{Q}")),
  s("RR", t("\\mathbb{R}")),
  s("CC", t("\\mathbb{C}")),
  s("FF", t("\\mathbb{F}")),
  s("PP", t("\\mathbb{P}")),
  s("HH", t("\\mathbb{H}")),
  s("Zn", fmta("\\mathbb{Z}_{<>}", { i(1, "n") })),
  s("Zp", fmta("\\mathbb{Z}_{<>}", { i(1, "p") })),
  s("Zx", t("\\mathbb{Z}[x]")),
  s("Qx", t("\\mathbb{Q}[x]")),
  s("Rx", t("\\mathbb{R}[x]")),
  s("Fx", fmta("<>[x]", { i(1, "F") })),
  s("poly", fmta("<>[<>]", { i(1, "R"), i(2, "x") })),
  s("cal", fmta("\\mathcal{<>}", { i(1, "F") })),
  s("bb", fmta("\\mathbb{<>}", { i(1, "R") })),
  s("mbf", fmta("\\mathbf{<>}", { i(1, "x") })),
  s("rm", fmta("\\mathrm{<>}", { i(1) })),
  s("star", t("\\ast")),
  s("times", t("\\times")),
  s("tensor", t("\\otimes")),
  s("oplus", t("\\oplus")),
  s("zero", t("\\{0\\}")),

  -- Relations and algebra notation
  s("iso", t("\\cong")),
  s("simeq", t("\\simeq")),
  s("sim", t("\\sim")),
  s("hom", fmta("\\operatorname{Hom}(<> , <>)", { i(1, "G"), i(2, "H") })),
  s("ker", fmta("\\ker(<> )", { i(1, "\\varphi") })),
  s("Ker", fmta("\\Ker(<> )", { i(1, "\\varphi") })),
  s("im", fmta("\\im(<> )", { i(1, "\\varphi") })),
  s("img", fmta("\\operatorname{im}(<> )", { i(1, "\\varphi") })),
  s("aut", fmta("\\Aut(<> )", { i(1, "G") })),
  s("inn", fmta("\\Inn(<> )", { i(1, "G") })),
  s("end", fmta("\\End(<> )", { i(1, "G") })),
  s("gal", fmta("\\Gal(<> / <>)", { i(1, "L"), i(2, "K") })),
  s("gen", fmta("\\langle <> \\rangle", { i(1, "x") })),
  s("gp", fmta("\\langle <> \\rangle", { i(1, "g") })),
  s("normal", t("\\trianglelefteq")),
  s("unlhd", t("\\unlhd")),
  s("nnormal", t("\\ntrianglelefteq")),
  s("ideal", t("\\triangleleft")),
  s("subring", t("\\leq")),
  s("quot", fmta("<> / <>", { i(1, "G"), i(2, "N") })),
  s("coset", fmta("<><>", { i(1, "g"), i(2, "N") })),
  s("rcoset", fmta("<><>", { i(1, "N"), i(2, "g") })),
  s("addcoset", fmta("<> + <>", { i(1, "r"), i(2, "I") })),
  s("mod", fmta("\\pmod{<>}", { i(1, "n") })),
  s("units", fmta("<>^{\\times}", { i(1, "R") })),
  s("unitstar", fmta("<>^{\\ast}", { i(1, "R") })),
  s("ann", fmta("\\Ann(<> )", { i(1, "M") })),
  s("char", fmta("\\operatorname{char}(<> )", { i(1, "R") })),
  s("ord", fmta("\\ord(<> )", { i(1, "g") })),
  s("gcd", fmta("\\gcd(<>, <>)", { i(1, "m"), i(2, "n") })),
  s("lcm", fmta("\\operatorname{lcm}(<>, <>)", { i(1, "m"), i(2, "n") })),
  s("deg", fmta("\\deg(<> )", { i(1, "f") })),
  s("sgn", fmta("\\sgn(<> )", { i(1, "\\sigma") })),
  s("orb", fmta("\\Orb(<> )", { i(1, "x") })),
  s("stab", fmta("\\Stab(<> )", { i(1, "x") })),
  s("cen", fmta("Z(<>)", { i(1, "G") })),
  s("cent", fmta("C_{<>}(<> )", { i(1, "G"), i(2, "x") })),
  s("clg", fmta("\\operatorname{Cl}_{<>}(<> )", { i(1, "G"), i(2, "x") })),
  s("Syl", fmta("\\operatorname{Syl}_{<>}(<> )", { i(1, "p"), i(2, "G") })),
  s("Sn", fmta("S_{<>}", { i(1, "n") })),
  s("An", fmta("A_{<>}", { i(1, "n") })),
  s("Dn", fmta("D_{<>}", { i(1, "n") })),
  s("GL", fmta("GL_{<>}(<>)", { i(1, "n"), i(2, "R") })),
  s("SL", fmta("SL_{<>}(<>)", { i(1, "n"), i(2, "R") })),
  s("Mn", fmta("M_{<>}(<>)", { i(1, "n"), i(2, "R") })),
  s("cl", fmta("\\overline{<>}", { i(1, "a") })),
  s("bar", fmta("\\overline{<>}", { i(1, "x") })),
  s("hat", fmta("\\widehat{<>}", { i(1, "x") })),
  s("til", fmta("\\widetilde{<>}", { i(1, "x") })),
  s("map", fmta("<> : <> \\to <>", { i(1, "f"), i(2, "A"), i(3, "B") })),
  s("colon", t("\\colon")),
  s("maps", t("\\mapsto")),
  s("to", t("\\to")),
  s("onto", t("\\twoheadrightarrow")),
  s("inj", t("\\hookrightarrow")),
  s("longto", t("\\longrightarrow")),
  s("xto", fmta("\\xrightarrow{<>}", { i(1) })),

  -- Greek letters
  s("al", t("\\alpha")),
  s("be", t("\\beta")),
  s("ga", t("\\gamma")),
  s("de", t("\\delta")),
  s("ep", t("\\epsilon")),
  s("vep", t("\\varepsilon")),
  s("ze", t("\\zeta")),
  s("et", t("\\eta")),
  s("th", t("\\theta")),
  s("vth", t("\\vartheta")),
  s("io", t("\\iota")),
  s("kap", t("\\kappa")),
  s("la", t("\\lambda")),
  s("mu", t("\\mu")),
  s("nu", t("\\nu")),
  s("xi", t("\\xi")),
  s("pi", t("\\pi")),
  s("vpi", t("\\varpi")),
  s("rho", t("\\rho")),
  s("vrho", t("\\varrho")),
  s("sig", t("\\sigma")),
  s("vsig", t("\\varsigma")),
  s("tau", t("\\tau")),
  s("ups", t("\\upsilon")),
  s("ph", t("\\phi")),
  s("vph", t("\\varphi")),
  s("chi", t("\\chi")),
  s("psi", t("\\psi")),
  s("om", t("\\omega")),
  s("Gam", t("\\Gamma")),
  s("Del", t("\\Delta")),
  s("Th", t("\\Theta")),
  s("Lam", t("\\Lambda")),
  s("Xi", t("\\Xi")),
  s("Pi", t("\\Pi")),
  s("Sig", t("\\Sigma")),
  s("Ups", t("\\Upsilon")),
  s("Phi", t("\\Phi")),
  s("Psi", t("\\Psi")),
  s("Om", t("\\Omega")),

  -- Reusable theorem statement shapes
  s("subgtest", fmta([[
\begin{theorem}[Subgroup Test]
Let <> be a group and let <> be nonempty. Then <> is a subgroup of <> if and only if
for all <> \in <>, we have <> \in <>.
\end{theorem}
]], { i(1, "G"), i(2, "H \\subseteq G"), i(3, "H"), i(4, "G"), i(5, "a,b"), i(6, "H"), i(7, "ab^{-1}"), i(8, "H") })),
  s("ringhom", fmta([[
\begin{definition}[Ring homomorphism]
A ring homomorphism <> : <> \to <> is a function such that, for all <> \in <>,
\[
  <>(<> + <>) = <>(<>) + <>(<>), \qquad <>(<> <>) = <>(<>) <>(<>).
\]
\end{definition}
]], {
    i(1, "\\varphi"),
    i(2, "R"),
    i(3, "S"),
    i(4, "a,b"),
    rep(2),
    rep(1),
    i(5, "a"),
    i(6, "b"),
    rep(1),
    rep(5),
    rep(1),
    rep(6),
    rep(1),
    rep(5),
    rep(6),
    rep(1),
    rep(5),
    rep(1),
    rep(6),
  })),
  s("subringtest", fmta([[
\begin{theorem}[Subring Test]
Let <> be a ring and let <>. Then <> is a subring of <> if and only if <> is nonempty and
for all <> \in <>, we have <> \in <> and <> \in <>.
\end{theorem}
]], { i(1, "R"), i(2, "S \\subseteq R"), i(3, "S"), rep(1), rep(3), i(4, "a,b"), rep(3), i(5, "a-b"), rep(3), i(6, "ab"), rep(3) })),
  s("idealtest", fmta([[
\begin{theorem}[Ideal Test]
A nonempty subset <> \subseteq <> is an ideal of <> if, for all <> \in <> and <> \in <>,
\[
  <> - <> \in <>, \qquad <><> \in <>, \qquad <><> \in <>.
\]
\end{theorem}
]], { i(1, "I"), i(2, "R"), rep(2), i(3, "x,y"), rep(1), i(4, "r"), rep(2), i(5, "x"), i(6, "y"), rep(1), rep(4), rep(5), rep(1), rep(5), rep(4), rep(1) })),
  s("quotring", fmta([[
\begin{definition}[Quotient ring]
Let <> be a ring and let <> be an ideal of <>. Then
\[
  <> / <> = \{ <> + <> \mid <> \in <> \}
\]
with operations
\[
  (<> + <>) + (<> + <>) = (<> + <>) + <>, \qquad
  (<> + <>)(<> + <>) = <><> + <>
\]
is the quotient ring of <> by <>.
\end{definition}
]], {
    i(1, "R"),
    i(2, "I"),
    rep(1),
    rep(1),
    rep(2),
    i(3, "r"),
    rep(2),
    rep(3),
    rep(1),
    rep(3),
    rep(2),
    i(4, "s"),
    rep(2),
    rep(3),
    rep(4),
    rep(2),
    rep(3),
    rep(2),
    rep(4),
    rep(2),
    rep(3),
    rep(4),
    rep(2),
    rep(1),
    rep(2),
  })),
  s("firstiso", fmta([[
\begin{theorem}[First Isomorphism Theorem]
Let <> : <> \to <> be a homomorphism. Then
\[
  <>/\Ker(<>) \cong \im(<>).
\]
The isomorphism is
\[
  \overline{<>} : <>/\Ker(<>) \to \im(<>), \qquad
  \overline{<>}(<> \Ker(<>)) = <>(<>).
\]
\end{theorem}
]], {
    i(1, "\\varphi"),
    i(2, "G"),
    i(3, "G'"),
    rep(2),
    rep(1),
    rep(1),
    rep(1),
    rep(2),
    rep(1),
    rep(1),
    rep(1),
    i(4, "g"),
    rep(1),
    rep(1),
    rep(4),
  })),
  s("lagrange", fmta([[
\begin{theorem}[Lagrange's Theorem]
If <> is a finite group and <> \leq <>, then
\[
  |<>| = [<> : <>]\,|<>|.
\]
In particular, |<>| divides |<>|.
\end{theorem}
]], { i(1, "G"), i(2, "H"), rep(1), rep(1), rep(1), rep(2), rep(2), rep(2), rep(1) })),
  s("orbitstab", fmta([[
\begin{theorem}[Orbit-Stabilizer Theorem]
Let <> act on <> and let <> \in <>. Then
\[
  |<>| = |\Orb(<>)|\,|\Stab(<>)|.
\]
\end{theorem}
]], { i(1, "G"), i(2, "X"), i(3, "x"), rep(2), rep(1), rep(3), rep(3) })),
  s("eisen", fmta([[
\begin{theorem}[Eisenstein's Criterion]
Let <> = <> \in \mathbb{Z}[x] and let <> be prime. If <> divides every coefficient except the leading coefficient,
<> \nmid <> and <>^2 \nmid <>, then <> is irreducible over \mathbb{Q}.
\end{theorem}
]], { i(1, "f(x)"), i(2, "a_0+a_1x+\\cdots+a_nx^n"), i(3, "p"), rep(3), rep(3), i(4, "a_n"), rep(3), i(5, "a_0"), rep(1) })),
  s("modptest", fmta([[
\begin{theorem}[Mod <> Test]
Let <> \in \mathbb{Z}[x] be nonconstant and let <> be prime. If <> is irreducible over \mathbb{Z}_{<>} and
\[
  \deg(<>) = \deg(<>),
\]
then <> is irreducible over \mathbb{Q}.
\end{theorem}
]], { i(1, "p"), i(2, "f(x)"), rep(1), i(3, "\\overline{f}(x)"), rep(1), rep(2), rep(3), rep(2) })),
  s("rrt", fmta([[
\begin{theorem}[Rational Root Test]
Let <> = <> \in \mathbb{Z}[x] with <> \neq 0 and <> \neq 0. If <> / <> \in \mathbb{Q} is a root in lowest terms, then
<> \mid <> and <> \mid <>.
\end{theorem}
]], { i(1, "f(x)"), i(2, "a_0+a_1x+\\cdots+a_nx^n"), i(3, "a_0"), i(4, "a_n"), i(5, "p"), i(6, "q"), rep(5), rep(3), rep(6), rep(4) })),
  s("kerideal", fmta([[
\begin{proof}
Let <> : <> \to <> be a ring homomorphism. We show \ker <> is an ideal of <>.

Nonempty: <>(0)=0, so 0 \in \ker <>.

Let <> \in \ker <> and <> \in <>. Then
\[
  <>(<> - <>) = <>(<>) - <>(<>) = 0 - 0 = 0,
\]
so <> - <> \in \ker <>. Also
\[
  <>(<><>) = <>(<>)<>(<>) = <>(<>)(0)=0,
\]
and similarly <><> \in \ker <>. Thus \ker <> is an ideal of <>.
\end{proof}
]], {
    i(1, "\\varphi"),
    i(2, "R"),
    i(3, "S"),
    rep(1),
    rep(2),
    rep(1),
    rep(1),
    i(4, "a,b"),
    rep(1),
    i(5, "r"),
    rep(2),
    rep(1),
    i(6, "a"),
    i(7, "b"),
    rep(1),
    rep(6),
    rep(1),
    rep(7),
    rep(6),
    rep(7),
    rep(1),
    rep(1),
    rep(5),
    rep(6),
    rep(1),
    rep(5),
    rep(1),
    rep(6),
    rep(1),
    rep(5),
    rep(6),
    rep(5),
    rep(1),
    rep(1),
    rep(2),
  })),
}
