---
layout: post
title: "Code Golf in Python: Sudoku"
date: 2013-04-15 16:00
comments: true
categories: 
---
<div class="ipynb">

<div class="text_cell_render border-box-sizing rendered_html">
<p><em>Edit: based on suggestions from readers, the best solution is down to 162 characters!
Read to the end to see how</em></p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>A highlight of PyCon each year for me is working on the little coding
challenges offered by companies in the expo center.
I love testing my Python prowess against the problems they pose (and
being rewarded with a branded mug or T-shirt!)
This year, several of the challenges involved what's become known as
<a href="http://codegolf.com/">code golf</a>: writing a solution with minimal keystrokes.</p>
<p>By way of example, take a look at this function definition:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [1]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span><span class="n">i</span><span class="o">=</span><span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">);</span><span class="k">return</span><span class="p">[(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span>
<span class="nb">set</span><span class="p">(</span><span class="sb">`5**18`</span><span class="p">)</span><span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">/</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">/</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">/</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">/</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">/</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">/</span><span class="mi">3</span><span class="p">)</span><span class="ow">or</span>
<span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:])),[</span><span class="n">p</span><span class="p">]][</span><span class="n">i</span><span class="o">&lt;</span><span class="mi">0</span><span class="p">]</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This is a valid function definition (in Python 3.3+) which executes a
particular task.  I'll give more information on the purpose of this
script later on, but for now I'll leave it to the reader to ponder
over what it might do.</p>
<p>Given the level of obfuscation involved, you might wonder what the point
is: you'd never want to write "real" code in this style, so why spend the
time doing it? I'd argue that it's useful for more than just upping your
geek cred: good Python code golf must utilize many quirks of the Python
language in seeking brevity above all else.  Learning to utilize these
quirks can lead to a much deeper understanding of the Python language.</p>
<p>I thought about putting together a list of tricks that can help lead to
short programs, but the problem is there are so many of them (and there
are other pages out there which do this adequately enough).  Instead,
I decided to simply work through a step-by-step example of creating
a code golf solution to a fun little problem: solving Sudoku.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p><img src="http://jakevdp.github.com/images/sudoku.png" width=400></p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<!-- more -->

<p>You've probably seen Sudoku: it's a puzzle consisting of a 9x9 grid
of numbers, with some spaces left blank.
The grid must be filled so that each row, column,
and 3x3 box contains the numbers 1-9.  It's a generalization of the
<em>Latin Squares</em> first studied by Leonhard Euler nearly 300 years ago.</p>
<p>The reason I chose to use Sudoku here is simple: not only is today
Euler's birthday, but Sudoku is how I first learned Python.
My first year of graduate school, my research advisor
recommended that I learn Python for the project I was working on.
Sudoku had just become popular in the US at the time, and I decided to
learn Python by writing a Sudoku solver.  I did it over my winter
break, and the rest (so it's said) is history.</p>
<p>Note that this is by no means a new subject: you can read about Sudoku
in Python in several places, and there are even a few code golf solutions
floating around out there.  In particular, you should take a look at
<a href="http://www.scottkirkwood.com/2006/07/shortest-sudoku-solver-in-python.html">this solution</a>,
which is the shortest solver I've seen, and from which I borrowed a few
of the tricks used below.</p>
<p>Here we'll pose the problem in a slightly different way, which will give
us the chance to develop a brand new short algorithm.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  The Problem
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Every code golf challenge must start with a well-defined problem.
Here is ours:</p>
<ul>
<li><em>Write a function</em> <code>S(p)</code> <em>which, given a valid Sudoku puzzle,
returns an iterator over all solutions of the puzzle.</em></li>
</ul>
<p>The puzzle will be in the form of a length-81 string of digits, with
<code>'0'</code> denoting an empty grid space.  The solved puzzles should also
be length-81 strings, with the zeros replaced by solved values.</p>
<p>For example, a valid <code>S(p)</code> may produce the following results:</p>
<pre class="ipynb"><code>puz="027800061000030008910005420500016030000970200070000096700000080006027000030480007"
for s in S(puz):
    print(s)

327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657

puz = 81*'0'  # empty puzzle
print(next(S(puz)))

132598476598476132476132985319825764825764319764913258981257643647389521253641897
</code></pre>
<p>Notice that the function <code>S()</code> cannot simply return a list of valid solutions:
if it did, then the empty puzzle example would need to produce all ~$10^{22}$
valid sudoku grids before the first solution could be accessed!
Instead, it must make use of Python's extremely useful
<strong>generator</strong> syntax.  If you've never used generators and
generator expressions in your Python code,
stop reading this right now and go learn about them: they're one of
the most unique and powerful features of the Python language.</p>
<p>As you'll see below, my best solution is <strike>176</strike> 162 characters, and is the
code snippet I showed above:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [2]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span><span class="n">i</span><span class="o">=</span><span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">);</span><span class="k">return</span><span class="p">[(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span>
<span class="nb">set</span><span class="p">(</span><span class="sb">`5**18`</span><span class="p">)</span><span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">/</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">/</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">/</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">/</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">/</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">/</span><span class="mi">3</span><span class="p">)</span><span class="ow">or</span>
<span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:])),[</span><span class="n">p</span><span class="p">]][</span><span class="n">i</span><span class="o">&lt;</span><span class="mi">0</span><span class="p">]</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>It's rather unenlightening in itself, so below I'll explain the steps
I took to arrive at it, in hopes that you can learn from my
thought process.  Though this is the best solution I was able to come
up with, I don't know whether or not a better one might be out there.
If you can beat it, please post your solution in the blog comment thread!</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Step 1: Focus on Correct Code
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>A code golf script must be more than simply short: it must be correct.
For this reason, I generally start by simply writing correct code, and
not for the moment worrying about brevity.</p>
<p>In the case of Sudoku, there are many rules and rubriks that can be used
to create an efficient solver (read about some of them <a href="http://www.sudokuoftheday.com/pages/techniques-overview.php">here</a>).
Using these, it is possible to solve most (all?) Sudoku puzzles without
resorting to guess-and-check approaches.  To implement this strategy,
one approach might be to enumerate the sets of possible values
for each grid space, and apply these rules to eliminate values until
only a single possibility remains within each space.</p>
<p>Unfortunately, this is not a very suitable approach for code golf:
the number of rules required to accomplish this is very large.  Instead,
we'll make use of the minimal amount of rules, and write a guess-and-check
based solver.</p>
<p>Here's a first attempt, focusing on the algorithm rather than on brevity.
We'll start by defining a test puzzle with four solutions, and write a
small function that can test our solver:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [3]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">puz</span> <span class="o">=</span> <span class="s">&quot;027800061000030008910005420500016030000970200070000096700000080006027000030480007&quot;</span>

<span class="k">def</span> <span class="nf">test</span><span class="p">(</span><span class="n">S</span><span class="p">):</span>
    <span class="c"># solve an empty puzzle</span>
    <span class="k">print</span><span class="p">(</span><span class="nb">next</span><span class="p">(</span><span class="n">S</span><span class="p">(</span><span class="mi">81</span><span class="o">*</span><span class="s">&#39;0&#39;</span><span class="p">)))</span>
    <span class="k">print</span><span class="p">(</span><span class="s">&#39;&#39;</span><span class="p">)</span>

    <span class="c"># find all four solutions of puz</span>
    <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">puz</span><span class="p">):</span>
        <span class="k">print</span><span class="p">(</span><span class="n">s</span><span class="p">)</span>
</pre></div>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [4]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="c"># Write functions that, given an index 0 &lt;= i &lt; 81,</span>
<span class="c"># return the indices of grid spaces in the same row,</span>
<span class="c"># column, and box as entry i</span>
<span class="k">def</span> <span class="nf">row_indices</span><span class="p">(</span><span class="n">i</span><span class="p">):</span>
    <span class="n">start</span> <span class="o">=</span> <span class="n">i</span> <span class="o">-</span> <span class="n">i</span> <span class="o">%</span> <span class="mi">9</span>
    <span class="k">return</span> <span class="nb">range</span><span class="p">(</span><span class="n">start</span><span class="p">,</span> <span class="n">start</span> <span class="o">+</span> <span class="mi">9</span><span class="p">)</span>

<span class="k">def</span> <span class="nf">col_indices</span><span class="p">(</span><span class="n">i</span><span class="p">):</span>
    <span class="n">start</span> <span class="o">=</span> <span class="n">i</span> <span class="o">%</span> <span class="mi">9</span>
    <span class="k">return</span> <span class="nb">range</span><span class="p">(</span><span class="n">start</span><span class="p">,</span> <span class="n">start</span> <span class="o">+</span> <span class="mi">81</span><span class="p">,</span> <span class="mi">9</span><span class="p">)</span>

<span class="k">def</span> <span class="nf">box_indices</span><span class="p">(</span><span class="n">i</span><span class="p">):</span>
    <span class="n">start</span> <span class="o">=</span> <span class="mi">27</span> <span class="o">*</span> <span class="p">(</span><span class="n">i</span> <span class="o">//</span> <span class="mi">27</span><span class="p">)</span> <span class="o">+</span> <span class="mi">3</span> <span class="o">*</span> <span class="p">((</span><span class="n">i</span> <span class="o">%</span> <span class="mi">9</span><span class="p">)</span> <span class="o">//</span> <span class="mi">3</span><span class="p">)</span>
    <span class="k">return</span> <span class="p">[</span><span class="n">i</span> <span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">3</span><span class="p">)</span> <span class="k">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="n">start</span> <span class="o">+</span> <span class="mi">9</span> <span class="o">*</span> <span class="n">j</span><span class="p">,</span> <span class="n">start</span> <span class="o">+</span> <span class="mi">9</span> <span class="o">*</span> <span class="n">j</span> <span class="o">+</span> <span class="mi">3</span><span class="p">)]</span>

<span class="c"># compute and store the full set of connected indices for each i</span>
<span class="n">connected</span> <span class="o">=</span> <span class="p">[(</span><span class="nb">set</span><span class="o">.</span><span class="n">union</span><span class="p">(</span><span class="nb">set</span><span class="p">(</span><span class="n">box_indices</span><span class="p">(</span><span class="n">i</span><span class="p">)),</span>
                       <span class="nb">set</span><span class="p">(</span><span class="n">row_indices</span><span class="p">(</span><span class="n">i</span><span class="p">)),</span>
                       <span class="nb">set</span><span class="p">(</span><span class="n">col_indices</span><span class="p">(</span><span class="n">i</span><span class="p">)))</span>
              <span class="o">-</span> <span class="nb">set</span><span class="p">([</span><span class="n">i</span><span class="p">]))</span>
             <span class="k">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)]</span>

<span class="c"># S(p) will recursively find solutions and &quot;yield&quot; them</span>
<span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span>
    <span class="c"># First, find the number of empty squares and the number of</span>
    <span class="c"># possible values within each square</span>
    <span class="n">L</span> <span class="o">=</span> <span class="p">[]</span>
    <span class="k">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">):</span>
        <span class="k">if</span> <span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="p">]</span> <span class="o">==</span> <span class="s">&#39;0&#39;</span><span class="p">:</span>
            <span class="n">vals</span> <span class="o">=</span> <span class="nb">set</span><span class="p">(</span><span class="s">&#39;123456789&#39;</span><span class="p">)</span> <span class="o">-</span> <span class="nb">set</span><span class="p">(</span><span class="n">p</span><span class="p">[</span><span class="n">n</span><span class="p">]</span> <span class="k">for</span> <span class="n">n</span> <span class="ow">in</span> <span class="n">connected</span><span class="p">[</span><span class="n">i</span><span class="p">])</span>
            <span class="k">if</span> <span class="nb">len</span><span class="p">(</span><span class="n">vals</span><span class="p">)</span> <span class="o">==</span> <span class="mi">0</span><span class="p">:</span>
                <span class="k">return</span>
            <span class="k">else</span><span class="p">:</span>
                <span class="n">L</span><span class="o">.</span><span class="n">append</span><span class="p">((</span><span class="nb">len</span><span class="p">(</span><span class="n">vals</span><span class="p">),</span> <span class="n">i</span><span class="p">,</span> <span class="n">vals</span><span class="p">))</span>
    
    <span class="c"># if all squares are solved, then yield the current solution</span>
    <span class="k">if</span> <span class="nb">len</span><span class="p">(</span><span class="n">L</span><span class="p">)</span> <span class="o">==</span> <span class="mi">0</span> <span class="ow">and</span> <span class="s">&#39;0&#39;</span> <span class="ow">not</span> <span class="ow">in</span> <span class="n">p</span><span class="p">:</span>
        <span class="k">yield</span> <span class="n">p</span>
        
    <span class="c"># otherwise, take the index with the smallest number of possibilities,</span>
    <span class="c"># and recursively call S() for each possible value.</span>
    <span class="k">else</span><span class="p">:</span>
        <span class="n">N</span><span class="p">,</span> <span class="n">i</span><span class="p">,</span> <span class="n">vals</span> <span class="o">=</span> <span class="nb">min</span><span class="p">(</span><span class="n">L</span><span class="p">)</span>
        <span class="k">for</span> <span class="n">val</span> <span class="ow">in</span> <span class="n">vals</span><span class="p">:</span>
            <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span> <span class="o">+</span> <span class="n">val</span> <span class="o">+</span> <span class="n">p</span><span class="p">[</span><span class="n">i</span> <span class="o">+</span> <span class="mi">1</span><span class="p">:]):</span>
                <span class="k">yield</span> <span class="n">s</span>

<span class="n">test</span><span class="p">(</span><span class="n">S</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">132598476598476132476132985351249768789361254624857319943785621817624593265913847

327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657
327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This is the test output we expect: it quickly finds not only the four solutions
of the test puzzle, but a solution derived from a completely empty puzzle.  This
is by no means a complete test suite, but it gives us good reason to believe
that the code is correct.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Step 2: Simplify the Algorithm
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>For me, the biggest hurdle to writing concise programs was letting go
of the compulsion to write clear and efficient code.
In my research, the two most important aspects of code are its scalability
and its readibility.  I need my code to work on extremely large datasets,
and I need a collaborator to be able to use my code to reproduce or extend
my results.  Code that doesn't meet these requirements is hardly worth
writing.  Code golf, though, is different: it's often an exercise in
sacrificing efficiency and readability at the altar of brevity.</p>
<p>For the Sudoku problem, we can start in two obvious places.</p>
<ul>
<li>
<p>We can condense the computation of the connected indices by using
  a nested list comprehension.  List comprehensions are a way of shortening
  a loop to a single statement.  In this case, the resulting algorithm is
  slightly less efficient, a bit less readable, but saves a lot of typing.</p>
</li>
<li>
<p>Rather than finding the grid space with the fewest possibilities
  to recursively guess at a solution, we simply choose any unknown
  grid space.  This can be much less efficient, but saves a lot of typing.</p>
</li>
</ul>
<p>Applying these two ideas leads to the following:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [5]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="c"># store the full set of connected indices for each i</span>
<span class="n">connected</span> <span class="o">=</span> <span class="p">[</span><span class="nb">set</span><span class="p">([</span><span class="n">j</span> <span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)</span>
              <span class="k">if</span> <span class="p">(</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">==</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="p">)</span> <span class="ow">or</span> <span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">==</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span>
                 <span class="ow">or</span> <span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">==</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span> <span class="ow">and</span> <span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">==</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)])</span>
             <span class="k">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)]</span>
<span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span>
    <span class="c"># find any grid space without a known value</span>
    <span class="n">i</span> <span class="o">=</span> <span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">)</span>
    
    <span class="c"># if no entry is zero, then yield the current solution</span>
    <span class="k">if</span> <span class="n">i</span> <span class="o">&lt;</span> <span class="mi">0</span><span class="p">:</span>
        <span class="k">yield</span> <span class="n">p</span>
        
    <span class="c"># otherwise, take this index and recursively call S()</span>
    <span class="c"># for each possible value.</span>
    <span class="k">else</span><span class="p">:</span>
        <span class="k">for</span> <span class="n">val</span> <span class="ow">in</span> <span class="nb">set</span><span class="p">(</span><span class="s">&#39;123456789&#39;</span><span class="p">)</span> <span class="o">-</span> <span class="nb">set</span><span class="p">(</span><span class="n">p</span><span class="p">[</span><span class="n">n</span><span class="p">]</span> <span class="k">for</span> <span class="n">n</span> <span class="ow">in</span> <span class="n">connected</span><span class="p">[</span><span class="n">i</span><span class="p">]):</span>
            <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span> <span class="o">+</span> <span class="n">val</span> <span class="o">+</span> <span class="n">p</span><span class="p">[</span><span class="n">i</span> <span class="o">+</span> <span class="mi">1</span><span class="p">:]):</span>
                <span class="k">yield</span> <span class="n">s</span>
<span class="n">test</span><span class="p">(</span><span class="n">S</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">132598476598476132476132985319825764825764319764913258981257643253641897647389521

327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657
327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This is good, but we can go further by moving the <code>connected</code> list
definition into the <code>S()</code> function.  Again, this is less efficient
than computing the sets once beforehand, but it saves some typing:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [6]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span>
    <span class="n">i</span> <span class="o">=</span> <span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">)</span>
    <span class="k">if</span> <span class="n">i</span> <span class="o">&lt;</span> <span class="mi">0</span><span class="p">:</span>
        <span class="k">yield</span> <span class="n">p</span>
    <span class="k">else</span><span class="p">:</span>
        <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span> <span class="nb">set</span><span class="p">(</span><span class="s">&#39;123456789&#39;</span><span class="p">)</span><span class="o">-</span><span class="nb">set</span><span class="p">(</span><span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span> <span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)</span>
                                      <span class="k">if</span> <span class="p">(</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">==</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="p">)</span> <span class="ow">or</span> <span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">==</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span>
                                      <span class="ow">or</span> <span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">==</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span> <span class="ow">and</span> <span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">==</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)):</span>
            <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:]):</span>
                <span class="k">yield</span> <span class="n">s</span>
<span class="n">test</span><span class="p">(</span><span class="n">S</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">132598476598476132476132985319825764825764319764913258981257643253641897647389521

327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657
327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We can go a little further by using a <strong>set comprehension</strong> for
the loop over possible values.  Set comprehensions are like list comprehensions
or generator expressions, but are denoted with curly brackets: <code>{}</code>.</p>
<p>We'll also use a trick here based on the way Python implements boolean logic.
    When you execute something like</p>
<pre class="ipynb"><code>(A or B)
</code></pre>
<p>you might expect the result to be either <code>True</code> or <code>False</code>.  Instead, Python
does something a bit clever.  If the result is False, it returns <code>A</code> (which,
naturally, evaluates to <code>False</code>).  If the result is True, it returns <code>A</code> if
<code>A</code> evaluates to <code>True</code>, and <code>B</code> otherwise.  We can use this fact to
remove the <code>if</code> statement completely from the set comprehension.  We'll end
up with some extra values within the second set, but the set difference conveniently
removes these.</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [7]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span>
    <span class="n">i</span> <span class="o">=</span> <span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">)</span>
    <span class="k">if</span> <span class="n">i</span> <span class="o">&lt;</span> <span class="mi">0</span><span class="p">:</span>
        <span class="k">yield</span> <span class="n">p</span>
    <span class="k">else</span><span class="p">:</span>
        <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span> <span class="nb">set</span><span class="p">(</span><span class="s">&#39;123456789&#39;</span><span class="p">)</span><span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">!=</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="p">)</span><span class="ow">and</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">!=</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span>
                                   <span class="ow">and</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">!=</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span><span class="ow">or</span> <span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">!=</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)</span>
                                   <span class="ow">or</span> <span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}:</span>
            <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:]):</span>
                <span class="k">yield</span> <span class="n">s</span>
<span class="n">test</span><span class="p">(</span><span class="n">S</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">132598476598476132476132985319825764825764319764913258981257643253641897647389521

327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657
327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Step 3: Combining Expressions
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now we have the basics of the algorithm.  We can keep shrinking the
implementation by combining the two loops into a single generator
expression.  It's important that we use a generator expression
(surrounded by <code>()</code>) rather than a list comprehension (surrounded
by <code>[]</code>), because otherwise all possible solutions would need to
be computed in order to return a single one!</p>
<p>For clarity, we'll create a temporary explicit container for the
generator, which we can remove later.
The result of combining the loops looks like this:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [8]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span>
    <span class="n">i</span> <span class="o">=</span> <span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">)</span>
    <span class="k">if</span> <span class="n">i</span> <span class="o">&lt;</span> <span class="mi">0</span><span class="p">:</span>
        <span class="k">yield</span> <span class="n">p</span>
    <span class="k">else</span><span class="p">:</span>
        <span class="n">g</span> <span class="o">=</span> <span class="p">(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span> <span class="nb">set</span><span class="p">(</span><span class="s">&#39;123456789&#39;</span><span class="p">)</span>
             <span class="o">-</span> <span class="p">{(</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">!=</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="p">)</span><span class="ow">and</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">!=</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span>
                <span class="ow">and</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">!=</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span><span class="ow">or</span> <span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">!=</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)</span>
                <span class="ow">or</span> <span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span>
             <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:]))</span>
        <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">g</span><span class="p">:</span>
            <span class="k">yield</span> <span class="n">s</span>
<span class="n">test</span><span class="p">(</span><span class="n">S</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">132598476598476132476132985319825764825764319764913258981257643253641897647389521

327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657
327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We can further combine the <code>if-else</code> statement into the generator expression
to save some more room: if there are no zeros in <code>p</code>, we'll just loop over
<code>[p]</code> instead of looping over the generator.</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [9]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span>
    <span class="n">i</span> <span class="o">=</span> <span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">)</span>
    <span class="n">g</span> <span class="o">=</span> <span class="p">(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span> <span class="nb">set</span><span class="p">(</span><span class="s">&#39;123456789&#39;</span><span class="p">)</span>
         <span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">!=</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="p">)</span><span class="ow">and</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">!=</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span><span class="ow">and</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">!=</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span><span class="ow">or</span> <span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">!=</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)</span>
         <span class="ow">or</span> <span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:]))</span>
    <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="p">(</span><span class="n">g</span> <span class="k">if</span> <span class="n">i</span><span class="o">&gt;=</span><span class="mi">0</span> <span class="k">else</span><span class="p">[</span><span class="n">p</span><span class="p">]):</span>  <span class="c"># parentheses here for clarity</span>
        <span class="k">yield</span> <span class="n">s</span>
<span class="n">test</span><span class="p">(</span><span class="n">S</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">132598476598476132476132985319825764825764319764913258981257643253641897647389521

327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657
327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Step 4: Sweating the Details
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We've condensed the script about as much as we can now, but there
are still some tiny changes we can make that will save a few
characters here or there.  This step is the difference between
a code golf amateur and a true code golf pro.  Some of the tricks
I apply here would not have been obvious to me had I not come
across
<a href="http://www.scottkirkwood.com/2006/07/shortest-sudoku-solver-in-python.html">this solution</a>,
so I don't think I can call myself a pro just yet!</p>
<p>First of all, we can shorten the definition of the full set of nine digits.
Observe:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [10]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">print</span><span class="p">(</span><span class="nb">set</span><span class="p">(</span><span class="s">&#39;123456789&#39;</span><span class="p">))</span>
<span class="k">print</span><span class="p">(</span><span class="nb">set</span><span class="p">(</span><span class="nb">str</span><span class="p">(</span><span class="mi">5</span><span class="o">**</span><span class="mi">18</span><span class="p">)))</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">set([&apos;1&apos;, &apos;3&apos;, &apos;2&apos;, &apos;5&apos;, &apos;4&apos;, &apos;7&apos;, &apos;6&apos;, &apos;9&apos;, &apos;8&apos;])
set([&apos;1&apos;, &apos;3&apos;, &apos;2&apos;, &apos;5&apos;, &apos;4&apos;, &apos;7&apos;, &apos;6&apos;, &apos;9&apos;, &apos;8&apos;])
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>One character shorter!  We're making progress.</p>
<p>Next, we can use compact bitwise operators to test whether
square <code>i</code> and square <code>j</code> are related.  Our previous
expression was</p>
<p><code>(i%9!=j%9)and(i//9!=j//9)and(i//27!=j//27or i%9//3!=j%9//3)</code></p>
<p>we can equivalently write</p>
<p><code>(i-j)%9*(i//9^j//9)*(i//27^j//27|i%9//3^j%9//3)</code></p>
<p>which saves about 12 more characters.</p>
<p>Further, observe that the variable <code>i</code>, which denotes the index
of the first zero in the puzzle string, will be <code>-1</code> if the
string has no zeros.  The bitwise inverse of <code>-1</code> is zero,
so <code>~i</code> will evaluate to False only if there are no zeros in
the puzzle.  This saves a couple more characters.  The result is:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [11]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span>
    <span class="n">i</span> <span class="o">=</span> <span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">)</span>
    <span class="n">g</span> <span class="o">=</span> <span class="p">(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span> <span class="nb">set</span><span class="p">(</span><span class="nb">str</span><span class="p">(</span><span class="mi">5</span><span class="o">**</span><span class="mi">18</span><span class="p">))</span>
         <span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)</span>
         <span class="ow">or</span> <span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:]))</span>
    <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">g</span> <span class="k">if</span><span class="o">~</span><span class="n">i</span> <span class="k">else</span><span class="p">[</span><span class="n">p</span><span class="p">]:</span>
        <span class="k">yield</span> <span class="n">s</span>
<span class="n">test</span><span class="p">(</span><span class="n">S</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">132598476598476132476132985319825764825764319764913258981257643253641897647389521

327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657
327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Finally, though it's standard to use four spaces for an indentation,
Python will also recognize one-space indentations, which save white
space characters.  At the same time, we'll remove other unnecessary
spaces, and move the definition of <code>g</code> into the statement where
it's used.  To make things easier to parse, we'll replace a required
white-space with a line break (between <code>or</code> and <code>p</code>).
Because this break falls
between two parentheses, the lack of indentation is still parseable.</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [12]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span>
 <span class="n">i</span><span class="o">=</span><span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">)</span>
 <span class="k">for</span> <span class="n">s</span> <span class="ow">in</span><span class="p">(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span> <span class="nb">set</span><span class="p">(</span><span class="nb">str</span><span class="p">(</span><span class="mi">5</span><span class="o">**</span><span class="mi">18</span><span class="p">))</span><span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)</span><span class="ow">or</span>
<span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:]))</span><span class="k">if</span><span class="o">~</span><span class="n">i</span> <span class="k">else</span><span class="p">[</span><span class="n">p</span><span class="p">]:</span>
  <span class="k">yield</span> <span class="n">s</span>
<span class="n">test</span><span class="p">(</span><span class="n">S</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">132598476598476132476132985319825764825764319764913258981257643253641897647389521

327894561465132978918765423589216734643978215172543896794651382856327149231489657
327894561465132978918765423589216734643978215271543896794651382856327149132489657
327894561645132978918765423589216734463978215172543896794651382856327149231489657
327894561645132978918765423589216734463978215271543896794651382856327149132489657
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We've gotten our solution down to 182 characters!
As far as I can tell, this is the best we can do
in Python versions less than 3.2. Python 3.3,
however, added the "<code>yield from</code>" statement, which
can help us further shorten this.  In a generator
definition, writing</p>
<pre class="ipynb"><code>yield from G
</code></pre>
<p>is (for our purposes, anyway) essentially equivalent to writing</p>
<pre class="ipynb"><code>for g in G:
    yield g
</code></pre>
<p>so it fits the bill exactly.  As a bonus, the removal of nested
indentation allows us to write things on a single line, using
the <code>;</code> character in place of a new line:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [&nbsp;]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span><span class="n">i</span><span class="o">=</span><span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">);</span><span class="k">yield</span> <span class="n">from</span><span class="p">(</span><span class="n">s</span>
<span class="k">for</span> <span class="n">v</span> <span class="ow">in</span> <span class="nb">set</span><span class="p">(</span><span class="nb">str</span><span class="p">(</span><span class="mi">5</span><span class="o">**</span><span class="mi">18</span><span class="p">))</span><span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)</span><span class="ow">or</span>
<span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:]))</span><span class="k">if</span><span class="o">~</span><span class="n">i</span> <span class="k">else</span><span class="p">[</span><span class="n">p</span><span class="p">]</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Using this new syntactic sugar buys us another twelve characters.
We're down to 176 characters: not yet tweetable, but I think it's
pretty good!  Once again, if you see any further abbreviations that
can be made, please let me know in the blog comments.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Another Approach
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>The other shortest sudoku script I've seen is this one, dating back eight
years or so and coming in at 185 characters (see the
<a href="http://www.scottkirkwood.com/2006/07/shortest-sudoku-solver-in-python.html">source</a>,
and note that due to the change in integer division syntax, the python 3 version,
here, is six characters longer than the python 2 version):</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [&nbsp;]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">r</span><span class="p">(</span><span class="n">a</span><span class="p">):</span><span class="n">i</span><span class="o">=</span><span class="n">a</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">);</span><span class="o">~</span><span class="n">i</span> <span class="ow">or</span> <span class="nb">exit</span><span class="p">(</span><span class="n">a</span><span class="p">);[</span><span class="n">m</span>
<span class="ow">in</span><span class="p">[(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)</span><span class="ow">or</span> <span class="n">a</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span>
<span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)]</span><span class="ow">or</span> <span class="n">r</span><span class="p">(</span><span class="n">a</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">m</span><span class="o">+</span><span class="n">a</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:])</span><span class="k">for</span> <span class="n">m</span> <span class="ow">in</span><span class="s">&#39;</span><span class="si">%d</span><span class="s">&#39;</span><span class="o">%</span><span class="k">5</span><span class="o">**</span><span class="mi">18</span><span class="p">]</span>
<span class="kn">from</span> <span class="nn">sys</span> <span class="kn">import</span><span class="o">*</span><span class="p">;</span><span class="n">r</span><span class="p">(</span><span class="n">argv</span><span class="p">[</span><span class="mi">1</span><span class="p">])</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This script has a slightly different purpose: it's meant to take an
argument in the command line and output one answer.  For this reason,
a direct comparison of the two solutions is somewhat misleading. Taking
away the command-line call brings the count down to 174 characters
(note the <code>from sys import*</code> is still required for the <code>exit()</code> call).
On the other hand, this script only finds a single solution,
and does it in a clever but unorthodox way:
in order to break out of the recursion efficiently, it returns the solution
as an exit code.  This works in the sense that the answer prints to the
screen, but means that the script is only useful as a stand-alone application.</p>
<p>Regardless of judgments about which solution "won" this round of code
golf, I hope you agree with me that this is a valuable exercise.
To me, the end goal of code golf is not simply a concise program: it's
the pursuit of a deeper knowledge of the ins and outs of the
Python language itself.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Update
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Several commenters on the blog and on reddit have suggested improvements to the algorithm.
First of all, the conditional of the form</p>
<pre class="ipynb"><code>(genexp if~i else[p])
</code></pre>
<p>can be made one character shorter by using the fact that boolean variables are interpreted
as either 1 or zero:</p>
<pre class="ipynb"><code>([p],genexp)[i&lt;0]
</code></pre>
<p>Also, it was pointed out that the <code>yield from</code> can be replaced by a simple <code>return</code> in
this case, because <code>yield</code> is not used anywhere in the function.  So the shortest version
of the function becomes this:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [13]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span><span class="n">i</span><span class="o">=</span><span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">);</span><span class="k">return</span><span class="p">[(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span>
<span class="nb">set</span><span class="p">(</span><span class="nb">str</span><span class="p">(</span><span class="mi">5</span><span class="o">**</span><span class="mi">18</span><span class="p">))</span><span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">//</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">//</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">//</span><span class="mi">3</span><span class="p">)</span><span class="ow">or</span>
<span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:])),[</span><span class="n">p</span><span class="p">]][</span><span class="n">i</span><span class="o">&lt;</span><span class="mi">0</span><span class="p">]</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This is 171 characters!</p>
<p>But there's more.  Now that the <code>yield from</code> is unnecessary, we can move to python 2.x and
change all the Python 3-style integer division operators (<code>//</code>) to Python 2-style (<code>/</code>).
This saves six more characters:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [14]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span><span class="n">i</span><span class="o">=</span><span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">);</span><span class="k">return</span><span class="p">[(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span>
<span class="nb">set</span><span class="p">(</span><span class="nb">str</span><span class="p">(</span><span class="mi">5</span><span class="o">**</span><span class="mi">18</span><span class="p">))</span><span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">/</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">/</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">/</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">/</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">/</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">/</span><span class="mi">3</span><span class="p">)</span><span class="ow">or</span>
<span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:])),[</span><span class="n">p</span><span class="p">]][</span><span class="n">i</span><span class="o">&lt;</span><span class="mi">0</span><span class="p">]</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>165 characters, but note that this requires Python 2.7.</p>
<p>There's one more thing we can add, as noted by a commenter below.
In Python 2.x, back-ticks can be used as a shorthand for
string representation (this is a feature removed in Python 3.x).  Thus:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [15]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">print</span><span class="p">(</span><span class="nb">str</span><span class="p">(</span><span class="mi">5</span><span class="o">**</span><span class="mi">18</span><span class="p">))</span>
<span class="k">print</span><span class="p">(</span><span class="sb">`5**18`</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">3814697265625
3814697265625
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>A problem, though, is that in 32-bit architectures, <code>5**18</code> is a long integer, so that
the string representation is <code>'3814697265625L'</code> (note the <code>L</code> appended at the end).
This would lead to incorrect solutions.  But as long as we're assured that we're on a 64-bit
platform, we can use this to save three more characters:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [16]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">S</span><span class="p">(</span><span class="n">p</span><span class="p">):</span><span class="n">i</span><span class="o">=</span><span class="n">p</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="s">&#39;0&#39;</span><span class="p">);</span><span class="k">return</span><span class="p">[(</span><span class="n">s</span> <span class="k">for</span> <span class="n">v</span> <span class="ow">in</span>
<span class="nb">set</span><span class="p">(</span><span class="sb">`5**18`</span><span class="p">)</span><span class="o">-</span><span class="p">{(</span><span class="n">i</span><span class="o">-</span><span class="n">j</span><span class="p">)</span><span class="o">%</span><span class="k">9</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">/</span><span class="mi">9</span><span class="o">^</span><span class="n">j</span><span class="o">/</span><span class="mi">9</span><span class="p">)</span><span class="o">*</span><span class="p">(</span><span class="n">i</span><span class="o">/</span><span class="mi">27</span><span class="o">^</span><span class="n">j</span><span class="o">/</span><span class="mi">27</span><span class="o">|</span><span class="n">i</span><span class="o">%</span><span class="k">9</span><span class="o">/</span><span class="mi">3</span><span class="o">^</span><span class="n">j</span><span class="o">%</span><span class="k">9</span><span class="o">/</span><span class="mi">3</span><span class="p">)</span><span class="ow">or</span>
<span class="n">p</span><span class="p">[</span><span class="n">j</span><span class="p">]</span><span class="k">for</span> <span class="n">j</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">81</span><span class="p">)}</span><span class="k">for</span> <span class="n">s</span> <span class="ow">in</span> <span class="n">S</span><span class="p">(</span><span class="n">p</span><span class="p">[:</span><span class="n">i</span><span class="p">]</span><span class="o">+</span><span class="n">v</span><span class="o">+</span><span class="n">p</span><span class="p">[</span><span class="n">i</span><span class="o">+</span><span class="mi">1</span><span class="p">:])),[</span><span class="n">p</span><span class="p">]][</span><span class="n">i</span><span class="o">&lt;</span><span class="mi">0</span><span class="p">]</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>That brings our best to 162 characters, though it requires Python 2.7 and
a 64-bit system.  Thanks to all commenters who suggested these improvements!</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This post was written in the IPython notebook.  The raw notebook can be
downloaded <a href="http://jakevdp.github.com/downloads/notebooks/SudokuCodeGolf.ipynb">here</a>.
See also <a href="http://nbviewer.ipython.org/url/jakevdp.github.com/downloads/notebooks/SudokuCodeGolf.ipynb">nbviewer</a>
for an online static view.</p>
</div>

</div>