---
layout: post
title: "Sparse Graphs in Python: Playing with Word Ladders"
date: 2012-10-14 21:23
comments: true
categories: 
---
<div class="ipynb">

<div class="text_cell_render border-box-sizing rendered_html">
<p>The recent <a href="http://sourceforge.net/projects/scipy">0.11 release</a> of scipy includes several new features,
one of which is the <a href="http://docs.scipy.org/doc/scipy/reference/sparse.csgraph.html">sparse graph submodule</a>
which I contributed, with help from other developers.  I'm pretty excited about this: there are some
classic algorithms implemented, and it will open up whole new realms of computational possibilities in Python.</p>
<p>Before we start, I should say: this post is based on a <a href="http://pyvideo.org/video/1346/lightning-talks-wednesday">lightning talk</a> I gave
at Scipy 2012, and some of the material below comes from a <a href="http://docs.scipy.org/doc/scipy/reference/tutorial/csgraph.html">tutorial</a>
I wrote for the scipy documentation.</p>
<p>First: what exactly is a sparse graph?  Well, a graph is just a collection of nodes, which have links between them.
<a href="http://networkx.lanl.gov/">NetworkX</a> has some good examples and diagrams.  Graphs can represent nearly anything:
social network connections, where each node is a person and is connected to acquaintences;
images, where each node is a pixel and is connected to neighboring pixels; points in a high-dimensional
distribution, where each node is connected to its nearest neighbors; and practically anything else you can
imagine.</p>
<p>One very efficient way to represent graph data is in a sparse matrix: let's call it <code>G</code>.  The matrix <code>G</code> is of size <code>N x N</code>,
and <code>G[i, j]</code> gives the value of the connection between node <code>i</code> and node <code>j</code>.  A sparse graph contains
mostly zeros: that is, most nodes have only a few connections.  This property turns out to be true in most cases of
interest.</p>
<p>The creation of the sparse graph submodule was motivated by several algorithms used in scikit-learn, including:</p>
<ul>
<li>Isomap: a manifold learning algorithm which requires finding the shortest paths in a graph</li>
<li>Hierarchical clustering: a clustering algorithm based on a minimum spanning tree</li>
<li>Spectral Decomposition: a projection algorithm based on sparse graph laplacians</li>
</ul>
<p>And many more.</p>
</div>

<!-- more -->

<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's take a look at the package, and some of the algorithms available.
Remember, this requires at least Scipy version 0.11, which was
released in September 2012.</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [1]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="c"># First the preliminaries: enter pylab inline mode, do some imports</span>
<span class="o">%</span><span class="k">pylab</span> <span class="n">inline</span>
<span class="kn">import</span> <span class="nn">numpy</span> <span class="kn">as</span> <span class="nn">np</span>
<span class="kn">from</span> <span class="nn">scipy.sparse</span> <span class="kn">import</span> <span class="n">csgraph</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">
Welcome to pylab, a matplotlib-based Python environment [backend: module://IPython.zmq.pylab.backend_inline].
For more information, type &apos;help(pylab)&apos;.
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's first list all the routines available in the module:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [2]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">csgraph</span><span class="o">.</span><span class="n">__all__</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [2]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">[&apos;cs_graph_components&apos;,
 &apos;connected_components&apos;,
 &apos;laplacian&apos;,
 &apos;shortest_path&apos;,
 &apos;floyd_warshall&apos;,
 &apos;dijkstra&apos;,
 &apos;bellman_ford&apos;,
 &apos;johnson&apos;,
 &apos;breadth_first_order&apos;,
 &apos;depth_first_order&apos;,
 &apos;breadth_first_tree&apos;,
 &apos;depth_first_tree&apos;,
 &apos;minimum_spanning_tree&apos;,
 &apos;construct_dist_matrix&apos;,
 &apos;reconstruct_path&apos;,
 &apos;csgraph_from_dense&apos;,
 &apos;csgraph_masked_from_dense&apos;,
 &apos;csgraph_to_dense&apos;,
 &apos;csgraph_to_masked&apos;,
 &apos;NegativeCycleError&apos;]</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Lots of good stuff there!  In order to show the utility of these routines, I'd like to introduce
an example of a problem that can be quite interesting: word ladders.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Example: Word Ladders
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p><a href="http://en.wikipedia.org/wiki/Word_ladder">Word ladders</a> are a game invented by Lewis Carroll, in which words are linked
by changing a single letter at each step.  For example:</p>
<pre class="ipynb"><code>APE -&gt; APT -&gt; AIT -&gt; BIT -&gt; BIG -&gt; BAG -&gt; MAG -&gt; MAN
</code></pre>
<p>Here we have gone from "APE" to "MAN" in seven steps, changing one
letter each time.  The question is, can
we find a shorter path between these words using the same rules?
As we'll see below, this problem is naturally expressed as a
sparse graph problem.  The nodes will correspond to individual words,
and we'll create connections
between words that differ by at most one letter.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h3 class="ipynb">
  Obtaining a List of Words
</h3>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>First, of course, we must obtain a list of valid words.  I'm running Ubuntu Linux, and
Linux has a word dictionary at the location below.  If you're on a different architecture,
you may have to search a bit to find your system dictionary.  But it's there somewhere...</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [3]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">wordlist</span> <span class="o">=</span> <span class="nb">open</span><span class="p">(</span><span class="s">&#39;/usr/share/dict/words&#39;</span><span class="p">)</span><span class="o">.</span><span class="n">read</span><span class="p">()</span><span class="o">.</span><span class="n">split</span><span class="p">()</span>
<span class="nb">len</span><span class="p">(</span><span class="n">wordlist</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [3]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">99171</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Our dictionary contains nearly 100,000 words.  We need to reduce these to just
the three-letter words, and also remove invalid words like acronyms, proper
nouns, and contractions.  We'll do that the following way:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [4]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">wordlist</span> <span class="o">=</span> <span class="nb">filter</span><span class="p">(</span><span class="k">lambda</span> <span class="n">w</span><span class="p">:</span> <span class="nb">len</span><span class="p">(</span><span class="n">w</span><span class="p">)</span> <span class="o">==</span> <span class="mi">3</span><span class="p">,</span> <span class="n">wordlist</span><span class="p">)</span> <span class="c"># keep 3-letter words</span>
<span class="n">wordlist</span> <span class="o">=</span> <span class="nb">filter</span><span class="p">(</span><span class="nb">str</span><span class="o">.</span><span class="n">isalpha</span><span class="p">,</span> <span class="n">wordlist</span><span class="p">)</span> <span class="c"># no punctuation</span>
<span class="n">wordlist</span> <span class="o">=</span> <span class="nb">filter</span><span class="p">(</span><span class="nb">str</span><span class="o">.</span><span class="n">islower</span><span class="p">,</span> <span class="n">wordlist</span><span class="p">)</span> <span class="c"># no proper nouns or acronyms</span>

<span class="n">wordlist</span> <span class="o">=</span> <span class="n">np</span><span class="o">.</span><span class="n">sort</span><span class="p">(</span><span class="n">wordlist</span><span class="p">)</span>
<span class="n">wordlist</span><span class="o">.</span><span class="n">shape</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [4]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">(585,)</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We're left with 585 three-letter words.</p>
<p>Next we need to figure out how to efficiently find all pairs of
words which differ by a single letter.  We'll do that with some
hard-core numpy type-wrangling, by converting the 3-letter words
into a [585 x 3] matrix of numbers:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [5]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">word_bytes</span> <span class="o">=</span> <span class="n">np</span><span class="o">.</span><span class="n">ndarray</span><span class="p">((</span><span class="n">wordlist</span><span class="o">.</span><span class="n">size</span><span class="p">,</span> <span class="n">wordlist</span><span class="o">.</span><span class="n">itemsize</span><span class="p">),</span>
                        <span class="n">dtype</span><span class="o">=</span><span class="s">&#39;int8&#39;</span><span class="p">,</span>
                        <span class="nb">buffer</span><span class="o">=</span><span class="n">wordlist</span><span class="o">.</span><span class="n">data</span><span class="p">)</span>
<span class="n">word_bytes</span><span class="o">.</span><span class="n">shape</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [5]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">(585, 3)</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Here we've converted the raw bytes of the characters to 8-bit integers.  This sort of strategy
can be dangerous if you're not careful with your types, but in this instance it works fine.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h3 class="ipynb">
  Word Ladders as a Graph
</h3>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>With our preliminary processing out of the way, we can get to the interesting
part.  We now have 585 points in three dimensions, and want to link all points
that differ in a single dimension.  One nice way to do this is to use the
hamming distance in scipy: it does precisely this:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [6]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="kn">from</span> <span class="nn">scipy.spatial.distance</span> <span class="kn">import</span> <span class="n">pdist</span><span class="p">,</span> <span class="n">squareform</span>
<span class="kn">from</span> <span class="nn">scipy</span> <span class="kn">import</span> <span class="n">sparse</span>

<span class="n">hamming_dist</span> <span class="o">=</span> <span class="n">pdist</span><span class="p">(</span><span class="n">word_bytes</span><span class="p">,</span> <span class="n">metric</span><span class="o">=</span><span class="s">&#39;hamming&#39;</span><span class="p">)</span>
<span class="n">graph</span> <span class="o">=</span> <span class="n">sparse</span><span class="o">.</span><span class="n">csr_matrix</span><span class="p">(</span><span class="n">squareform</span><span class="p">(</span><span class="n">hamming_dist</span> <span class="o">&lt;</span> <span class="mf">1.01</span> <span class="o">/</span> <span class="n">wordlist</span><span class="o">.</span><span class="n">itemsize</span><span class="p">))</span>

<span class="n">graph</span><span class="o">.</span><span class="n">shape</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [6]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">(585, 585)</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We're left with a 585 x 585 graph of our word data.  To get a feeling for what 
this looks like, let's visualize it with matplotlib</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [7]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">fig</span> <span class="o">=</span> <span class="n">plt</span><span class="o">.</span><span class="n">figure</span><span class="p">(</span><span class="n">figsize</span><span class="o">=</span><span class="p">(</span><span class="mi">8</span><span class="p">,</span> <span class="mi">8</span><span class="p">))</span>
<span class="n">ax</span> <span class="o">=</span> <span class="n">fig</span><span class="o">.</span><span class="n">add_subplot</span><span class="p">(</span><span class="mi">1</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">1</span><span class="p">)</span>
<span class="n">ax</span><span class="o">.</span><span class="n">matshow</span><span class="p">(</span><span class="n">graph</span><span class="o">.</span><span class="n">toarray</span><span class="p">(),</span> <span class="n">cmap</span><span class="o">=</span><span class="n">plt</span><span class="o">.</span><span class="n">cm</span><span class="o">.</span><span class="n">binary</span><span class="p">)</span>

<span class="c"># Label axes with the words</span>
<span class="k">def</span> <span class="nf">formatfunc</span><span class="p">(</span><span class="n">x</span><span class="p">,</span> <span class="o">*</span><span class="n">args</span><span class="p">):</span>
    <span class="k">if</span> <span class="n">x</span> <span class="o">%</span> <span class="mi">1</span> <span class="o">!=</span> <span class="mi">0</span><span class="p">:</span>
        <span class="k">return</span> <span class="s">&#39;&#39;</span>
    <span class="k">else</span><span class="p">:</span>
        <span class="k">return</span> <span class="n">wordlist</span><span class="p">[</span><span class="nb">max</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span> <span class="nb">min</span><span class="p">(</span><span class="nb">int</span><span class="p">(</span><span class="n">x</span><span class="p">),</span> <span class="n">graph</span><span class="o">.</span><span class="n">shape</span><span class="p">[</span><span class="mi">0</span><span class="p">]</span> <span class="o">-</span> <span class="mi">1</span><span class="p">))]</span>

<span class="n">ax</span><span class="o">.</span><span class="n">xaxis</span><span class="o">.</span><span class="n">set_major_formatter</span><span class="p">(</span><span class="n">plt</span><span class="o">.</span><span class="n">FuncFormatter</span><span class="p">(</span><span class="n">formatfunc</span><span class="p">))</span>
<span class="n">ax</span><span class="o">.</span><span class="n">yaxis</span><span class="o">.</span><span class="n">set_major_formatter</span><span class="p">(</span><span class="n">plt</span><span class="o">.</span><span class="n">FuncFormatter</span><span class="p">(</span><span class="n">formatfunc</span><span class="p">))</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_display_data">
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAeIAAAHaCAYAAADcwEpjAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
AAALEgAACxIB0t1+/AAAIABJREFUeJztnXusXlWZ/5/zaztBaaHF28SkMhOiYKXtObahNkB6GExn
TESUmZJIwAoJTb0kJkqYMkZpwyUQMTMQqIlmIAjFCIIzYkQbJUcRbdRjRdKKRu0BL/EyttRSKpd0
//4o72F3d1/W2ntdvs9a309yQjnve/Z+1rOetb7rvsaKoiiEEEIIIVH4f7ENIIQQQnKGQkwIIYRE
hEJMCCGERIRCTAghhESEQkwIIYREhEJMCCGERIRCTLJhZmZGli5dGtsMkgCXX365PPHEEyIicv31
10e2hmhnjPuISS7MzMzIeeedJ48//nhsU0hCLFiwQA4cOBDbDKIY9oiV8eSTT8oXvvCF2GZE5Zpr
rpHTTjtNzj77bLnooovk05/+tPzkJz+Rt73tbbJ8+XK54IIL5OmnnxYRkenpaVm+fLmMj4/L1q1b
I1uOwfz580VE5Pe//72sW7dOREQee+wxeeihh2KaBcnMzIycdtppcvHFF8uSJUtk3bp1cujQIZmc
nJTp6WnZtGmTHDp0SCYmJuSSSy6JbW409u/fL5/5zGdim6EWCrEy9uzZI/fcc09sM6Lxwx/+UB54
4AH56U9/Kg899JD86Ec/EhGR9evXy6c+9Sl57LHHZOnSpbJlyxYREbn00kvltttuk5/85CcxzYZi
bGxMRERe//rXy3333SciIjt37pSvfe1rMc2C5Re/+IV86EMfkt27d8sJJ5wgW7dulbGxMRkbG5Mb
brhBXvGKV8jOnTvlrrvuim1qNPbt28eG7gC8CPF73vMeWblypZx++unyuc99TkREvv71r8uKFStk
fHxc3v72t4uIyMGDB+Wyyy6TVatWyVvf+lb5yle+4sMcFXz+85+f7bm9733vk0svvVTuv//+2c8X
LFggIiKbNm2SRx55RCYmJuTmm2+OZW40Hn30UXn3u98tf/d3fyfz58+X8847Tw4ePChPP/20nH32
2SJyRJS/853vyP79+2X//v1y1llniYhk3WOpYzRn/sILL8gnP/lJ+eIXvygTExOz4kyOsHjxYlm9
erWIiFx88cXy3e9+N7JFeGzatEl+9atfycTEhFx55ZVy0003yRlnnCHLly+XzZs3z37v7rvvllWr
VsnExIRs3LhRDh8+HM9oIOb6eOjtt98uixYtkkOHDskZZ5wh559/vmzYsEEeeeQROfnkk2eHDa+7
7jo599xz5fbbb5enn35aVq1aJW9/+9vlla98pQ+zYNm1a5dcd9118v3vf19OOukk2bdvn3z0ox+t
/e6NN94oN910kzz44IOBrcRgbGxMupY1NH3O5RD1zJs3T6655hqZnp6WW265JbY5cIxGEESOxFD5
/8kRbrzxRtm1a5fs3LlTtm/fLvfff7/84Ac/kMOHD8v5558vjzzyiLz61a+We++9V773ve/JnDlz
5IMf/KBs27aNDWTx1CO++eabZXx8XFavXi2/+c1v5LOf/aysWbNGTj75ZBERWbhwoYiIbN++XW64
4QaZmJiQc845R5577jn5zW9+48MkaB5++GG58MIL5aSTThIRkUWLFjV+N3cxOfPMM+XBBx+U5557
Tp555hn56le/Kscff7wsWrRotqdy1113yeTkpJx44omycOFCefTRR0VEZNu2bTFNh6Yoiuxjq4mn
nnpKduzYISIi99xzz+wIy4h58+bJiy++GMM0GMqxs337dtm+fbtMTEzIihUr5Oc//7n88pe/lG99
61syPT0tK1eulImJCXn44Ydlz549Ea3GwXmPeGpqSr71rW/Jjh075LjjjpNzzjlHxsfHZ5f6V3ng
gQfkjW98o2szVFHXy5s7d+7ssM3hw4fl+eefj2EaHCtXrpR3vetdsmzZMnnd614nS5culYULF8qd
d94pGzdulGeffVZOOeUUueOOO0RE5I477pDLLrtMxsbGZO3atezNEGtOPfVUue222+Syyy6Tt7zl
LfKBD3zgqBGpDRs2yLJly2TFihVZzxOXueqqq2TDhg1H/e7WW2+V9evXc7tXHYVj/vd//7c477zz
iqIoip/97GfFcccdV9x3333F4sWLiz179hRFURR/+ctfiqIoiv/4j/8oPvzhD8/+7Y9//GPX5qhg
165dxZve9KZZv/zlL38prr322uLf//3fi6Ioii9/+cvF2NhYURRF8aMf/ahYs2ZNLFMheOaZZ4qi
KIqDBw8WK1euLHbu3BnZIl3Mnz+/KIqi2LNnT3H66acXRVEU999/f7F+/fqIVmFS9hFp5v/+7/+K
k08+uSiKovjGN75RrFq1arac/va3vy3+9Kc/Fbt37y7e+MY3Fn/605+KojhSzz355JOxTIbC+dD0
v/zLv8iLL74oS5YskauuukpWr14tr33ta+Wzn/2sXHDBBTI+Pi7vfe97RUTkE5/4hLzwwguybNky
Of300+Xqq692bY4KlixZIh//+MdlzZo1Mj4+LldccYVcfvnl8u1vf1vGx8dlx44ds1tOli9fLnPm
zJHx8fEsF2uJHOmBjIa9/u3f/k3Gx8djm6SK8qjA6N/nnHOO7N69m4u1auAoSjevetWr5Mwzz5Sl
S5fKN7/5Tbnoootk9erVsmzZMrnwwgvlmWeekTe/+c1y7bXXytq1a2X58uWydu1a+cMf/hDbdAh4
oAchhBASkc4eMbciEUIIIR7pGrveu3dvURRF8eyzzxann3568cc//rFYvHhxMTMzUxRFUezbt68o
iqK46qqrirvvvnv2d29605uKgwcPHvM8EeEPf/jDH/7wJ6ufNjqHpjdv3iz/8z//IyJHDgC44oor
5Oc///kxqwNXrlwpzz33nMyde2Qh9r59++Qb3/iGnHrqqUd9bzTfMpoPnpyclMnJyTYTjvn7OpNN
9pdqZPPmzUdtiCfd0Gd20F920F925OivqakpmZqamv3/LVu2tOpT6/YlX1uRygaNhLl4aaN8l5g2
fZ6iCBNCCNFHtYM5OnK3idY54r/+9a+yaNEiOe644+SJJ56QHTt2yN/+9jf5zne+IzMzMyIisnfv
XhER+ed//uejTuXZuXNnp7FV4XUlplzlSAghRAutQhxiK5KPIeWUesc2w/bkCPSZHfSXHfSXHfRX
N8G3L5WHous+q/6+a07Y5PMRKQk0IYQQHXR1OKMI8eiVTf8m8WA+EEKIW7rq1aj3EfuYHybDYD4Q
QkhYogpxG6OLt0f/JoTg07essoyTnIEUYl+rqVOGFZlf6F8z+pZVlvF6GHf90eQ7SCEW4VylLRp9
pamgaPQv0Y/vuNNUBm3RVGajCHFd5ldXN9cd+lH3/aZAKn9eHuYmOGgqKISkCMsgBlGEuC7zm4S3
qWc8+l3XSVsjUWfA2cPGi3voU0JIFcihac4PY0Dfu6e6t50QQiCFuA0OM8eBPncHGziEkDLRhLhP
xd62gItC4ReKByGE+CGaEPet2LvmjAkhhBBNQK6abvp93aIrrpomhBCimdb7iH1h06M16enWXSTR
taqaEEIIQUBVj7j6e5M5Y/aICckXlnuiAch9xDa/r4pxuXc8+oz7iAkyFAt/sNwTDahaNd30d2Ux
5h5kog3GKSF5E2WOWMTN4fB1z6ibLyaEEEJQUXegRx3l+eCuM6oJIYQQJNQIcZuoNokve8WEEELQ
UbNqumn/cN0+46owc9U0IYQQVNSvmq4eol8VXK6aJoQQEhLbjp+aHnHT76vzwuVtTeXvskfsB/qV
EEKOxrbjp2aOuC9th36Q4dC3hBAyjOSFWIRi7Bv2itOFeasD5pNuxorAChVbFOsCts2eJntjp4MQ
QogOuvQiix7xCNP7jKsrsdvEmy3RsLjwN3qeMY3p4jvdCH5FsEEbWfWIq+dQj2DPNj84okEICQV7
xDWYVMJs1dmjyWcUYTs05a0pMdOUoj/LxEhf2zvR/Z2lEIvUi7HJkLTJc/t8FhNXdnG4Pl1SPDo2
Zpr61i9aiOHbtsY1esM7WyEWad6D3PT/5b9roq2AuQgGH0HtOkhDBb1LX6BWiq7scpk+VyKC5PMY
jcgQ70TwMZoIIvikSlZzxG30ubUJNS0I0Dd4ME9wYd6EJ5TPTbQl6x7xiL4tJBacZlIfetMI88SM
GD7yWZeg5DmKHSNC1d8m78laiOvOpW77vM8zcyZkQyVlv7seVnb9zCGg2FHGRT2ABEoDLGTv0/ff
uH4Gh6Zr4NYmf2jIf0R8+I15QUgYuH3JgLbbm0z/jpihseJHyGcf2+1c95QQ/JQK9GVeZCvEXb1e
E8HQKCooaKpoNORzX1F1mTYNfhoKwlYcVyCUQQQbysSyJ1shrqu4qj3jPoUBLbBQ0Vxpo+bxEJ+i
pAnFjiY0x20VhL3haGsWYs2nZzVH7FpcUyqUhBBC/MA54hJtrZ2meeImB6K15Kqg2tWFNrtD25vD
pQEkT3KOvayEWKS5F9t2wlZba2Zor9hX8GntrWuzO7S9vt+nzf8kHRCGyusIYUt2QtwXX0PqKHv8
kKA/0iGXvMwlnaFAahCGsIVCbIFPMR49n2AVwpxxEY+55GUuZTj19MUieyG2DSyfVyiyd0yQyEVE
XZK6z1JPXyzmxjYgJHUi6mO/8JBgRQ90nsZECCFuyapH3EdATK9CzKUnm8sQHCGEhCIrIRZpFpC2
Yy7r/qY8jFz+7+gnddgrbiZE/ucQY9phHrknVZ9mJ8R9ti+1iQ6HarFJ7Uq7kO9wTaqVaBO+8wjF
nyHt0Bj3JmQnxCO6gif1yx802TzEVi6AwyHVSrQNn7GHEtsodmgmWyHuqhRczicjkpOtmtJK0sK3
SKHENoodWslWiEW654J9bG3qA1ubOuFxlG4Zkt6YvvItxrnFQYpkdelDHX3sGf0NL4PQA1rcEULy
oav+yWofcR1DhqD7HOwxEvC+4p8rQ9OvxXdD06khTjTYSOxhvvYn66Fpn3RdFGG7WAx9QYRv29DT
7woX8+Gu/eT6eQiVdYqxFDtNqGUU0aYqFGKPDLm1qe3qRUQ0btlBLqBDV4oPfUbd81IiZppSvnEN
wYYqiDZVyVaIQ1XCbe9BFoI+aEsPcgF1YZvL9GnLWxNipQm15+iSGOnTXNdmK8QI98giCIHLAM2h
gskVtLx1eTNUqoe+xCSGb9t8iha/VbIVYpGwQdK1kCFWa851gKIHPOkP0jnjLoUsVswi+NE3SPUB
cuMnayEOnTFtAdnVmvOJ6+cjB3wdKBVFFRd2+Uibtvw1IYZg+HwnUkynGC/OF0Tmvo/YF0N6wDn4
xyepxpjvdLl6fqr+jwX9qZ+uPMy6R+yTttauScFCatFqI0TvJsV5RVfPH+p/TbEfwtYYvXVNeZAC
FGID+gZl3x5x19+aoLUgadlyE2u+VEsDI4fDV0TC2YqwuNQ3WussF1CIDfDZIvUV8JoqszLa7E6t
gtTmf5IO5dhDEuUQtlCIDRkixl0roof0nFMkxzSnSi55mUs6Q4HUIAxhC4XYgr4Z0jWMOfQ4zNRw
Ffiht6el8i7X29lyIPVyGittKfu0DIXYEhdHDzY9t+9xmKSekH5L6V1I+4U1kbIYx4qJXOo+CrEl
vvf+pVyYiS5yqQRdkrrPUk9fLLK/BrEPLm7IacLHnkHN+xA1204IcQNCPeDTBvaIPdH3yMryEFD5
Zwiae9mxCx/BQFv8+rRXmy9cgFCH+ayLnAvxk08+KV/4whdcP1YdLo6sdH2erkiehTgk9K8ftDXI
fNqLIEojUC510I5zId6zZ4/cc889rh+rmq5gHXICly0pBzMC9C8JAUqcodiBiE0jxfis6c9//vPy
6U9/WsbGxmTZsmUyZ84ceec73yn/+q//KiIiCxYskAMHDsjb3vY2eeKJJ+Qf//Ef5f3vf7985CMf
Oca4FDPPZD+wTbqrmZiizwgJQap1DtFDVwwaLdbatWuXXHfddfL9739fTjrpJNm3b5989KMfrf3u
jTfeKDfddJM8+OCDjc/bvHnz7L8nJydlcnLSxAxoqk6uOt62Iqj7flmcbZ+nvTLSbr8pQ9OpwU+h
bUT3RypoiL1QTE1NydTUlPH3jYT44YcflgsvvFBOOukkERFZtGhR43dNMqIsxKkymsdxeTjFkGe6
tqeK70Lo234UXKzId+0n189DyMMUYyl2mlDLaAybqh3MLVu2tH7faI64LiFz586Vw4cPi4jI4cOH
5fnnn7c0NX1cL6rouxK7bI8vQgS6j21dqLg4OAbhAgdUYqZJ27n12myogmhTFSMh/qd/+ie57777
ZO/evSIisnfvXvmHf/gHmZ6eFhGRr3zlK/LCCy+IyMtzxeQIrnsS1e1Npu9BFp1YIBdQF7Yhpy9n
mC/xQasPjYR4yZIl8vGPf1zWrFkj4+PjcsUVV8jll18u3/72t2V8fFx27Ngh8+fPFxGR5cuXy5w5
c2R8fFxuvvlmr8bnRPVmEpPC3CbUoQIRLeCJW1LO35TTFgsUn7oaNXKVHuNV065AnEPQxijz6UeC
wpByraFO0GBjFymkAZk2/3buqqEQ68dmqxP9T0g/WHZIX7pih0dc1oAyfGJCUwY3pQGhIvF5aQYh
vghddhjP+QArxDGDEEGsbKgTY+Q0+LLNZ5pZKZLQIB1lqRFNvoMV4thCgp6JVfvq7B263cknsd9v
S+x4NEGbTzWS0n28CPHi04Y+vovlE1ghjg16xdtkX/U0L9Qh6tjv7wtC5dWEVp9qIqXLUxDSghaz
sezhfcTKaVulR9yDVnGQOKQUBymlRSvsEStH25B0G8i21aHNXqIbxlu6UIgjMqRgmewlrvtsyHCU
74pAW8vchb2sXOuhX44lRvmIkQ9IeW9rS1/buY84MXh9YngY0yRlGN/D4T5iJfg6oB+pdRmaUGkP
vc3E97tyjpkhpOq3mNuoUvVpFfaIlVD2W18f1gU184JoQFu9ofnKUVQ0p5s9Yo/4bK3VDTEPOWNa
cxAT/QwtK9piV/uVo4iknG4K8QB8FzaT+V6bCo5i7J9chtJsYdy5BSXOUOzQDoUYGJPKy7aCoxj7
BeGQBJI+KGUYxQ7tUIiVYlLRN31Hmxij3Blqgyb/En/ksrAOxQ6tcLFWJnChFiGExIGLtV4i1Rab
abqKopgNhPK/Q9pA9MG81QHzSTfZCPHQhU4u8PE+W0H1sc+Ye5fTBaHchED7CVLIo1spxotrODRN
CCGEeIRD06Q3GlqyGmwkhJA2oISYlWpcNJ5TrcFGQghpA0qIWanGpe+JXWxAEUJIf+bGNoBgUhZX
26sWCSGEmAPVI26CPa44UGTdw1gmhFRRIcQUhDhwhbt76E9CSBUOTZNaKBiEEBIGFT1iEhcOpxJC
iD8oxBHRciA8e8f+YCOnHvoFA+0njg3F1pa+tvNkrZ6kko4+mK6oJoQQksHJWrFaTykLUJtPqyLM
fcQEGcYm0YB6IU5ZEEPQ93pEXzc5EeISxibRgHohJsPoU1GxciOEEHdQiMkxtA3n1V15yOE/Qgjp
TzZCTLHwB3vI6cJyowPmk26yEeIYYuG6cIQqbDa+Kn931Dv21UtmZWOG6wvnU/R7amlCyScEG6og
2lQlGyEeETJTXIs/cs/T5gpF01XZVVxVNugFc6h9ritlH3EXOw9ilSWf6UYQYwQbqiDXmyOyE+IU
C+AQXNtV598mkW5bsd1kl4v8Qy+YqGlEEneXtmhunId+vq0NSPUeki1VshPiMqELIGIguLarbuN6
U+XA6xV10dVIConL+IhVNhH86Bukeg+5TslaiENnDGoguLbLpuChFNKUCTHqoZ0YafL9TpSylWK8
uIa3L0nex1W6pG5rU9d36Hf/lHuy9DcmPvKGed1OqPJg0iDKukc8QmPAorR2R1SHoEb/bvIte83h
QZ83RiOluWMUkOLFxbC5yd+b5C2FWCmIBbcusJtanV2FIObFEkiVBTqIceiKlNMWCzSfDrXHVXoo
xIpBFAyTVdNt3zX5zDdolYUGhsQiYhxX0WBjFymkAZkh/qUQK0abYGizl5gzJG81xIUGG7tIIQ3I
DPEvF2tV4IIWN9gc6EF/d+MjLhnrhGDAHnEFbRUT8nBTnW19T9XKHR9xqS3WY8P4JL6gEDegpdAh
VaZ1PV2b+WEXK6xzhn7yC9LhFC5ASAuCDWVi2QMtxDEzCUngtFBXUTVVXl3DojFXTWuFfvJPSj5G
aFig+TOWPdBCHDuTYgepRprEuA6be4+RSDEuUNKEYkcuoBxbGvv9ZaIcd1oErvG4QITUwbgghKRK
V/0G3SMm6dC1SIvzw0QbqcZmqulChkIcgRwD3fTqw/JP+TMbUvWv73S5en6q/q8SagQntD85MhUe
CnEEcgl0k0sfTD+zgRVk3OfnEt+hQJnHJf6gEFvgqyCkWsBsK+QhveAYaLEzJqnGdpUQ6WS8pQuF
2AJfBSGlAmZziEfb71PySc4MyUdNIs54dY+m/B8KhdgSn8GRQuDZHNTRto8xBV9oJ3YeaBS32D7z
Da+G9AOF2BKfweFrLgihcug6YWvUCy7/INidMzlVhK5I3Wex0odQF/i0gUIMiOtgt7macAhtw9JV
G0wO/XDlB4RCTPJEy0r3ofi2A6GB49MGCrEjUAqEKb4uETA94rKrx1v+bKhvEQoxiUfKR+WixDaK
HVqhEDsiRK8TWezbVjy3zRE3Uf6sLNp1e43b7MmRnOLOhFAjQrFBSBOCDVUQbaqSnRBrXmyA3OoM
YZuriyLQC6aLEQCXafSRt7HzIMW5ToR1FQg2VEGuN0fwrGmiAq0XRBBCCM+aBgCthaid6rC1DcwL
UibFeEBJE4odrrFJl+l3sxdibSfipBrcNvQ5gavrb1D9inr+s4vnIfi8azV/CFy/s5ymlBeq9SXk
4k/T73JomngjRF6bzguTI7D8dZOaj1DSg2JHDDg0TaIRotDlWrD7Qn91k5qPUNKDYgciFOISCENl
xI62IedU8jPU4SsxQLGjDQ02dpFCGkzok06EaRZvQjwzMyNLly719XgvaL1uLCd76w4M6bNPWRO+
Dl9BAMWONlLY6qTBzy7ok04Xvhn6DPaIa0DcC9eGtkI2xL999gdryssh5JLOmGg+h6AKQrwg2FAm
lj1zu75wzTXXyLZt2+Q1r3mNLF68WFasWCHnnnuubNy4UQ4dOiSnnHKK3H777bJw4UKZnp6Wyy67
TMbGxmTt2rUh7PeGz0KQ86KFEX22HXX9Td1q0bYesza6fDA0na7iMuX4jpEuX/5EyCMEG8rEsqdV
iH/4wx/KAw88ID/96U/l+eefl7e+9a2yYsUKWb9+vdx6661y9tlny9VXXy1btmyR//zP/5RLL71U
tm7dKmeddZZceeWVjc/dvHnz7L8nJydlcnLSVXpUMOoRogUhMjY+G33P95WVofNPy7nFQ+NbU9kI
YWuM+kJTHiAyNTUlU1NTxt9v3b70X//1X7J//365+uqrRUTkYx/7mJx44ony3//93/Lkk0+KiMiv
f/1rWbdunTz88MOybNmy2d8//vjjctFFF8njjz9+9AuVZrAvu7X6AxluaSJEN0j1ogtbBm1fsh0O
NPm9VnydXZyan2LQtICrvPiu65II4h/63y0o/vRhB1K9GMKWViE+88wz5cEHH5TnnntOnnnmGfnq
V78qxx9/vCxatEi++93viojIXXfdJZOTk3LiiSfKwoUL5dFHHxURkW3btnk3HgWkoDEFpRCb0GVr
VyNp9LnGfEqJHP2f+iUPSHZopnWOeOXKlfKud71Lli1bJq973etk6dKlsnDhQrnzzjtl48aN8uyz
z8opp5wid9xxh4iI3HHHHUct1soxc3wMqfh4pqZK0WZeuPq78n9D43t4DWn4LgQa553LozK+Flwh
xEHs92un84jLgwcPyvHHHy/PPvusrFmzRj73uc/J+Ph4/xcCBI1vckgjAiZ+7nMuNSGEuKSrrurc
vrRhwwbZvXu3/O1vf5P3v//9g0Q4F1jp+2UU1CZ+rm5pYt4QQtDgpQ8ecZ1WZN+FuuDB1T7XOpqe
3TTsnUteIKe1L0xTujZUQbCJlz5U0HwyTuxgaiPUBQ8u8s/W1rrvtx2HOtRGF9e0oR+PGHv9SArH
VlZBWDSFYEMV5HpzRHZCHDpT0IJSOy57xE2Lu9r+xsSeoTa6qMwQK8QyGipHH/jOFwS/ItigjeyE
ODQMSj+4ujGlnD91R2RWP/PRA67DRdyk2JNNAdYJ8UCN36yFOHSmoAaBa7tCpNNVZWY7X1zXo2nq
5aDm9xDQe9p9iZGmFP1YB1I6URtBWQtx6ErF50KjIWidyw4xD1r3DtPhaKT8du0rVyMSKLSNeGh+
J4KP0cQPwSdVuGqaqKdvTLUdAlIG5dAEQohOuGo6URBbdXUgD1PbLNaiCNejJQ77kHLaYoHm09g7
HEZQiJWiRRg0zilq8S0CKfsq5bTFAs2nLnY4uIBCTLyDVvjKNC2yspkz1tbQcE3u6Sd54yL+KcSK
YQU4HNsVz7aHe+TA0FEPDX7TYGMXKaQBERfln0KsGOSepibatiq5eE4ODEm7Br9psLGLFNJgQqwG
xxD/dl76QEgu2PZ2kSo2lyvHQ9tAjoW+7I9Gv7FHrBwON/mnbUuTyXdD4GrleAwbtKDtzAGiB1gh
psCYkfv85BCqPrPdvuTrEA+CSYy8ZbnujybfwQoxKzQ7KMj2VHu1bWdNN10UUfddkj6h8jxEPZhq
/GrSEFghRkBjgGoKPgRsF2rVzd2hDVP3AcVWFDu6SKmcIez1j/3+MlHOHecRl+GhD/wSwr+2l0W4
eqeG5zO+3UJ/6odHXALCQlWPq5ZoKP+GHqb2nS5Xz2d8u4XTTulDITZAYwHQaHOoITKXNxqZDlO7
wrd/NMZNLqTewMk59ijEBvhukWq42jAUIcS4zTdt7zadB/bpey294hG5VK65pNMnWussF1CILfAV
KAiLJZBwecCEy3fbHu6hqeHm6/m5VK6pl+FYaUvZp2UoxCDkUmGFxNSntoW9SXTrhql9EKJX7LIC
TP0c6hHnzqG8AAAgAElEQVQpbzWK1dBAOcfce+OXq6bzgH4PQ7XA0udu0Ba/Pu3V5gtXaE43V00r
xscQoaYeBjro50+nhDa/+l4ngFKOeeynGyjEwPgIPKRCHBMXPmibF0650iDxQYkvFDu0QyF2gDZh
y6nwtB28YXPWtG0ea4uJENAnbkHxJ4odmqEQO6DtjGIXMND7Y7IK2va7CNuYmt6JzFB/ICzaQXo/
ynRTTg17X3CxFiEeYbwTQuAXa8VuzRHik7Zei83QOCEkXaILMXsLJAcY54SQJqILsQnsKcSBfndL
1x5jijUheaJCiLnlJg4UBrfQn4SQOlQIsQgrMaKfcmNybGxs9v/ZyCQkb9QIMSHaKTcmy4u42Mgk
JG8oxBHRdIuOj+flzEiAKcL1MNYwiJEPSHkf6iAf9UKMlGm2aLtblqJhT9vJXl3fyZmYV2GSl4lR
5pHqGVtb+tquXoi5kIsgYyK4SBVPatC3RAPqhViEhY3gUzcXzAYkIUQkESEmBJmmBVlsQBJCRCjE
3uBCKbdoTr+t4I62NlW3OJn4QIOfNNhI7GG+9odC7AnXN6Pk3nvykX7EiqPpPmPTFdYaFoHlHsuo
+TKU3PN1CBRiz6BcVdZEzj135IrDhR9dpw8pb13aEjpdyHHnmlRjxjUU4kCgFj5uccItoC586TJt
SHnr0paYjWVf70SJ6VRjxrV/KcQlUIKX2DMk79Aqi/IwdJ1tNkdjNqUNJdZR7BCJ4ytfsZfrCv0+
6ezzN679O1YEroXQj/RDt0879G87bf5x7TvmBSFh6Cpr7BFX0HhAiCZ7ffpXkx+aaPLPqCC7vCiC
IoxNCvFMzKAQ1+C7gnJdwLRVqL6H4zRXYCa9VF89WVd+0+x/JFKIZ2IGhTgCbfN+ZDgxKjCf29Sq
vWFf6XP1XG0NQ1f4ijcEf8aqn3KpFynEPfARHGz9uidkBebrXW1HY4Za6EPMSNlvsdKWsk/LUIh7
4PPQhFwCL2UGr6As/X3dHcZstOmA+eOeVH1KIX6JvhlM4SRVhsZE29/XCXOoO1N9PQcRLobDJFWf
UohfQlsGa6kEtdiplbJ/TX3tKtY17jAwJeW0xQTNpy5Hr4ZAIVaKloaD9mFUDXa3Hf4R6t0pknLa
YoHmU5+jVzZQiBvQUAFrQutJP2gVRxXtDR1tpORnhLQg2FAmlj0U4gY4NOUXdIFrAzUuhtiFkiYU
O5rQHLdVEG7qQmtIxqr3KcQtDCl0Od9q5AOk9PusjIcsGixXanU/be8KWQG1vSclodNE7AtGkPI9
hi3ZCXGoyoa3GrnFZcsZSdSrDBVEkz3GbXceh/BNzqNNvtMd069ovVtNZCfEoQWNQekWF/mHXmG4
EKq2YzBNt0f5JNeGpe9GCIJfEWzQRnZCHJqcW/++8HmcJAohhwpzjs8Yadd2ln1fUOxwjU26TL9L
IQ4AcoWvEdf+RK0wQh0qkfPZ57EXLPk6Lhch/1Kt92z8a+qD7IUYIWBt0GavT1z2jBH96mqIevQs
23ebPHcIaD6PEQe+3ok+/RITxFPTxorAzRZeRk5IHKoVEMshCUWK9b5Nmrq+m32PWIStRh/Qp/Fo
8n3OQ9DopJ4PiCIc6rpPk/dQiAV3aFIziAUvReritime64aph5x4lnKZiTFETcKCtEOAQvwSLAhE
I322KLk6UCPlMpNy2ggeFOISKbfwUyflvPO5mKfuHSF9qSHfNNjYRQppMKFPOhEWHg4W4vnz54uI
yO9//3tZt26diIg89thj8tBDDw19dHDYCtYL4rGTrjBJm6mQVo/CrPt+X1/28ZOGMhfDRtcxp8HP
LuiTTpeHBPVlsBCPAub1r3+93HfffSIisnPnTvna17429NHEgNgikQMaKrG2ed/y76vx0hU/NvGl
wU9DCFnWUvclORpnQ9MzMzOydOlSeeGFF+STn/ykfPGLX5SJiYlZcSZ+iH0gQU6k4N+6Ch7hyEsR
fP9yb64f6E+Rua4fOG/ePLnmmmtkenpabrnlltrvbN68efbfk5OTMjk56doMJ2jb+6bJVo2UK2Lt
vq4OZVcbdDHSN+qxo/sW3b4+xPQ7Wr67sGVqakqmpqaMv+9ciEWOnoeqoyzEyGiueDXaLKLD7pii
Zfq+tu81fVb+fd8TuYaCnvepEtvvSGLswoZqB3PLli2t3+eqaQN8D0mFWBWrBW17ulGFyma42eeK
aU15OYRc0ukTrXWWC7wI8QknnCAHDhzw8eio+AoUbeLjG1d+TnUbjuvtFtX4cxnnuVSuqZfhWGlL
2adlnK2aLv/7nHPOkd27dye5WMtXYKRekGMQUgSQ39V0+lbT/8caltZOymU41kK1XGKQlz4MJLX0
kOGEiImud/SZIzZ5LjGHvnSPVp/y0oeX8NmTzZ1UewF9CRETXe/oK7SMZ3dw65d7Uo3PbIR4yOH2
pB3ur9RDn4qsfAJX+af8mUZi2p76yVkxfNv2TvQ4zUaIq7C16p5QPs3Fn0jYXK1o8ncIxJzTTflI
VpE4vg010uPjhrJshTgkyIs4NG5XQWv950Ksc3zrcBVnyGWzLyjlA823LmPG9XezFuLQZ8ciBeUI
13ahppMMB2k1testVmhDqamAVB8gxG0TWQsx6mEMoXFtF2o6m0CpKKogXM9m+kzN83Mi8YZSNR0S
1Bdt9YEJrv2btRCLYAWsCdrs9Unqw5Mu7PK1kK5tH3LXd0eg+TwlMeYCymZc+MR144L7iF8C1S5C
2ugTty5j3deJXLFhfUBcwn3EhrDQkTJaehKhF1DVnaRn87yU/UryxEVMU4hLaKkkyLGkvC8z1Dyv
CXVDqTbP0rifX4ONXaSQBhP6pNPF9M/QZ1CISyBVvibkUrhM0JZ3NvhI25Bn1v1t13Gbbc9Cj2MN
NnaRQhpMiLXFbqh/IeeIOT9DiD6GlFuWeZIyKueIWSDzIYdWek4MGfImJFcghTh1KD4v46MCTtW/
vtPlYq6svG2mei416Qf9lz4U4giw9e+XVP3rO12utzRpXJiFSKrxXEeuMUIhNiSHE3AIcUk1tnMS
FNIPxINIQthCITbE5wk4SEGHAP2RDrmIL2PWLUhxE8IWCrEFvoba6jIaae9oaJAKITGPm+qQdPW/
WuKvD4xZMgQK8QB89mbR9o4Sc0IITuibw0xsKH+P88N5ptk3qfqUQjwQDi1jEyNvQjR4EBpVJucB
2Hw/NXynF6XeQWgUaodC7IBUgyMFmDdusbkCsa2HTIaD4lMUOzSTnRCjtCJJP1Dv6HUJchptj7es
Y2Qbej74AH0veCo2aCM7IY7RemNgusPlHb2ouDr7FhmbnnVoO3wSYi947Pom9cV5Nuky/W52Qlwl
RLC4LHypBrcNPgo6ql9d2eU6fT4uV4/ReEBYVObz5rCYcY3aGAzZkDf9LuSlD8QM+pKg0DcWu/4O
JcZR7BhCCmlAps2/Ki99iAlqz6gOjYVKk3+RQN9XbhOL5ffWnU1d99zYcaOxrFVJIQ3IDPEvpBBz
OCVd6N9+aNlXblJ2+yz4YtyQlIEUYpRCF7sVTjBJMS58nhJn8t6miyLqvkvcE9u3sd9fJso6Ac4R
k5gwHohI/XA1IanAOWJQkFqAMfFV6eawXxMZW/+M7jLumjNGI5R9of2A7vfUoBBHIsR+P8QtK6HQ
dndvagzxj6ZRklB2hvZHzEVySGXC1pa+tlOII+J7v5/rwqulchwRskD3fVffLT8+iem3tlO3kCro
OtDt60MMQUbZBy1iXz771pEUYhC0iZwGQvo05IlG2k5nantW9V1th3ygl5EQ9sUSplgndg19L+qB
OMc8n4u1CCGEEH9wsRapJfaQjw1DbdWUVnKEuiFrjfmY0jRCGyh2aIVC7Bj0E5BGaBqVGGprrLTm
UgkPoWmO2MUtT23vCYXvOVaESx5GdpD+cGiaEKKKqlizTiHocGgaBIRWax05b3EidiDkbV2PuUuE
u+xGSFeqIPkWyZYqWQtx6CX5iIHg2i7UdJLhoFzAYGpDWbRtVm6HAsGPvkGqD5BHTTg0TQhRS119
wjqGoMGhaUJIMjRdk9j1O0KQoRATQtRQJ7JNQ5/l36MMjxJSB4WYEKKa6kUR1d9X/00IGhRiQoh6
UpoXTr33jpi+2DZBCnFspxBC+tG37A4t8yMRHrqVCYFUGhRNIKYvtk2QQhzbKYSQfvQtu6FuoWLd
QhCBFGJCCOnCZI+qhh4wIRRiQoha2MMlKaBeiNniJSRfurYuUaiJBtQLMUpBY4OAkHB0CW3daVuE
oKJeiFFAaRAQkgO25Y3lkyCTvBCzJewX+pfEpGtouu6+Y8YsQSN5IWZL2C/0L4lJ19B09XPGK0Ek
eSGOSU53/YawDTn9SOQUd32oHolZ/bEByTcItiDYUAXRpiq8BpEQkh1d9xMT4hJeg9iAhlaSNujT
dEkxb/sch+mqx5yiP8vESF/bO9H9na0Qh2z1ogeBK0L5NBd/IpFiL7Grl1J3clfTaV5NMWm6vcol
COXD5NQzH+/s85ktNuky/W62QhySFCuxmLgs5AiVliZS81dXeurKbpNA932Ha1DqGxQ7yrjIC5t0
mX43ayEOXUBQKzGNi3tcFXLEygKZGD2dENgKad3323rFLoa5tYKUTtTynrUQh84U1CBwbRdqOptA
qijKuLDLR9q05a8JbcPUpo0P26FRn40apJhONV6cPo+rpgkh5GVs53tJNynW+zZp4qppEg2kVjk5
AvOkm6YKU6vvEOxOcUrDZcOCQvwSqQUJAqm1gBGxjVsudOumqfdiG88o/kEphyh2IEIhfgkGCRHB
qTxN6RO3XOj2Mn2uUTRdeKVVuEl4KMTEO5oqmBSH0EgzXfltKrAuGiUpNGxIPyjEJVgB+yFEBeMy
79AqRB9xiRLrCHZ0ibHNgpw+n4Ug9vtD0SedCLsTnAnx5ZdfLk888YSIiFx//fWuHhsUtArYhFwK
WBca884UH2lD8ReqHUVRzP6UP2+7HCLUyU59iP3+UMSaqhn6DC/blxYsWCAHDhyof6GCZewabCxD
e/0+l+RHXSzZnKbV9IyhNhCdON++NDMzI6eddppcfPHFsmTJElm3bp0cOnRIJicnZXp6WjZt2iSH
Dh2SiYkJueSSSwYZHwtt84TaCqsv/2rzg2s0xSwCXcPRQxdgDY1z3/GMEC8INpSJZU+voelf/OIX
8qEPfUh2794tJ5xwgmzdunV2uOaGG26QV7ziFbJz50656667XNsbDI2VOlpQt0H/uqevT1HSFeNM
ZlsxburZaDwEBME2tE5PLJ/M7fNHixcvltWrV4uIyMUXXyy33HKL1d9v3rx59t+Tk5MyOTnZxwzv
aBsa0mSrRsrzhCn5elQZxk5TDDu68rTOpqaecpvtCP5tI6Z9KPE3woUtU1NTMjU1Zfz9XkJcDsQ+
LZqyECODEhg5gFQQu9Bipw0oaYopBiL1cVhdsNX1DNvPEKg2NHI+h9+FLdUO5pYtW1q/32to+qmn
npIdO3aIiMg999wjZ5111lGfz5s3T1588cU+j84GpOEYBFwXRN/+Zf61M8Q/IXzrcii5vJI6hUsc
0IaLc6CXEJ966qly2223yZIlS2T//v3ygQ984KjPN2zYIMuWLVO7WCsESC3AFPHtX+ZfO0P8E8K3
rt4RSrBi9FApxuGw3r40MzMj5513njz++OP9XqhoCLIKt92Egf5IB/S87LKvaRtTeShb5GjhQk4v
iYOX25dybSn5KmBsfR6Ntt5Kau9K+ZSyKlVBrfvcZP+wiaBrJpb92v1mCu8jJrAwVgghKcD7iBXi
uhWotVXJkQISGpt467q5ibgDwac+bWCPOBPod6IZjfFreySmzXO1+cIFmtPNHrFnEFpqJmgNYI3E
3H6TKqHjd6h/fYpGrmU55REyCvFAcjgPltihaftN7nTtJ677fMjvyDA0xb1N/lOIHcKLDAjRRZ/T
skxXUpu+g6SJTb5TiB3ia+iELWudaNpmpAGfp3W1fW56C1Pb4i2fYpxbHKQIF2sRQgghHuFirQps
PerGRf6hxwDTmDbVs6ldboNC8CuCDdrIToi1rb4kR+Mi/7pOU4qNiykO9BWmuY6K2YwIduWh6ZB5
aBBs0EZ2Qhwa9ApRI678iVxhuGxwkGZilE2bHnCfRWAo9Q2KHa5xcehLlayFOPTNKaiBqe0kLwpM
XFDjuA8xy2bTvce2+Do4ZCjo9V5fbPxr+t2shTjny6/LuLYLNZ1NoFYUqHPF2vLXhBgjV30Wrg5d
wR2DFOPFeeeFq6YxbdIOfYoH8wSb6pWK5bxi3rknlE9NrsekEBNCSGTKPSzWj+nB7UuEWIA0pEfi
EzIeKMD5QiEmpAQrQ1ImZDxwtDBfKMQV2CPyC/3bDx6dmjZFURwzJ9x04AfzLT0oxBXYIvWLRv8i
VHxdfutjo+uVwgh+0krbFqRqPmksQ6QdCnEN2ioU2uv3uRoqvr42ukybBj/FpuvaxfL3qmJM0oVC
XIO2oNe2cV7rhela/GsLSrpQ7OhiiJ2tW1gyHYLOJZ1tcPtSBOgDv6Tq3xDX6bl4fqr+jwnq6VnE
DG5fAoTnT/slhH8RjkREff5Q/2sqG65sbesNxxim1pQHKUAhjkTdnBBxh28xjpl/GhoZQ8RCU2+v
utLZhrYFWDbxFeIY01j1Uy71IoUYBE2VjxZC+jTkKEeInjHKampNFbFtvvTxc907QsR5rFE8lNEV
741fzhHnAf1ONKMtfl3aW/esHOeMtcVAGc4Re0ZLi11rAGskRExoiTtXaIvfpp5cn7tsUYaJY5Py
2hoK8UBSDo4USHFRVah3uCa3ctI0jGzqh67vosQAz+MeDoXYARqDQ1OlOHTfpqa0pozGcjKUpvuD
bcS47dkIPmUZGw6F2DFazgRGKMCmDLU1Vlo1rG7WBMKiHVuaDttxJV5IYkz6w8VahBCSAKbHZ46+
y3o4HFysFRHXrXDkHhAXKOGQU9z1JcU02Qirj0tEhvydTxBtqpKdEGteWIDcgtW0lxG9YA61z/Wc
nY+8jZ0HKU5XuOzlDrlEJHbeVkGuN0dkJ8RDTsIZClqAjtDUg3JRqNALJnoaY5+85YMYh7GEXE/S
9a6hn5fhdit7shPiMqErA7TKZ0ROPfc6UCsK1N6/tvw1IUZPzuc7647MHLIVaoitKcaL63zLWogJ
EcGtKFz1jFEbGmjEiANf76wbpnax+4CxdATX+TbX6dMIIXCgNjSIW0wOEHElxrbPSXGVtss0sUdM
vMHWMx7Mk25S85Hreek+z0uxN+2yYUEhLpFaoMQmZAs45bzzsQIaxV8odpRJbbFRuefWVCb7LtZy
uWXKBX3yCmEtBoW4hLahE+0VhEu05Z0NPtLm+plDFvKgx7EGG6tU7e0aRvW5WCskfeIaYS0GhVgx
KYsP0cWQWNQQxxpsLNO2UMvl6mcN4hyKITFCISaEkESp9oS7esZjY2NG4jr6Xl/xQRTwmDbxrGlC
CMmQuosoQr8/Fy3gWdMZgdjKTIlU/YuSLhQ7ukC307RHGxu0hYMxgRZiZpAd2lqX2vJXm39NQUkX
ih1doNuJtpJZgw2xgRZiZpA9msRNY/5q8i/xRypxYDI8nEpakYEWYmKPNnHTVsi1+Zf4QUMcmJat
ru/FvCgnF3jEJYmKhgqNEI302Tc8dL8x6Qd7xIQQkih1Pdi2qxJND6Yw3eZEzKAQR4AB7JdU/es7
Xa6en6r/YzHEn00XQbR9dyTGTT+j77B37A4KcQS0HBenlRD+jZF/vis+V88f6n9NZSOErTa9VJfv
JOHggR6EEEKOom2YmvW3PTzQAxhtvTZNPRUt0Kf10C/+MblxyVR0XeYXUt7b2tLXdgpxREIMNXK4
yj+u5/AI/RICk5OtTMXYZX4h5b2tLX1tpxCD4KsViBTUoQnVsg49569tJCUXkP3WZltX/MacTkT2
qUsoxCDkLJi+COnTkGKsbSQll4VbSBff113o0CXGXc+LUUehLPzz3vjlYi17fKYhBf8QQjCoq0/a
6hgTwSmLI+sqM7rqdZ6s1QOfwcfAJoS4wmYfcddnQ75L2uHQNCGEJIrNyVqjz0xXU2uaNkCHQpwJ
LDREM9ri16e9Ns/u0yPu6uk2ncDlG20xYAOFGBgfW49SDmYE6F8/aBsG9T19ZRNn5e+6js/QCyJT
hULsAE1bj1IO5jpCC2Nu/rWBjRR32IhxOSZdxycXl7qBQuwAn4HIymsYrCRwYF64ZcjKZ5ewjqrH
xi8UYk+4Ck4OKR8hl/QPTacGP2mwUTOhh4vL88ptNzYNRVvc2OQDhdgTPo6XRA5E37ahp98VQytR
H37SPK/YRIqxFDtNvoep+z47tl9MyE6IQ2aK66BEqMCaCGGbK5FBL5hD7dNwxnjsPEjxyEaExuoQ
MfZ11SNyvTkiOyHmUK8/Qt3NivAMnyCmkb1iN/iuf1D8ajp/Xf5/E9+0pa9rfzQyRkK8f/9++cxn
PuPblqCEDFj0IHBFKJ/m4k8kECp418TsQaa+wLNJjKu/q8uDvr5xdWJYF323jrVhJMT79u2TrVu3
Gr+cHA3CkFET6POJdaQoChpAimGXiyGR0uUClPIx9ApF1LrJxzGgRkK8adMm+dWvfiUTExNy5ZVX
yk033SRnnHGGLF++XDZv3jz7vbvvvltWrVolExMTsnHjRjl8+LCxwamDUjiq5DSPnSsxKiDfpHr/
rUsQGhg+7uru+0zkfDa69OHGG2+UXbt2yc6dO2X79u1y//33yw9+8AM5fPiwnH/++fLII4/Iq1/9
arn33nvle9/7nsyZM0c++MEPyrZt2+SSSy455nll8Z6cnJTJyUlX6SGEVECugIg/Que7yVWKJt8b
+p5QtPX4p6amZGpqyvhZRkJcftn27dtl+/btMjExISIiBw8elF/+8pfy2GOPyfT0tKxcuVJERA4d
OiR///d/X/u8shCTdOGpO3gwT7pJzUcI6Unxoog2n1Y7mFu2bGl9Vq9rEK+66irZsGHDUb+79dZb
Zf369XL99df3eSRJkNiFnxwL86Sb1HxUTk8sUR6JMO8yrsdojnjBggVy4MABERFZu3at3H777XLw
4EEREfnd734nf/7zn+Xcc8+VL33pS/LnP/9ZRET27t0rTz31lCezCSHkaFLpbfneaxyL8q1NXZhc
xeiS2LFj1CN+1ateJWeeeaYsXbpU3vGOd8hFF10kq1evFpEjIn333XfLm9/8Zrn22mtl7dq1cvjw
YZk3b55s3bpV3vCGN3hNACGEiKTTw/KdjthD1Sbvr35e/Rsfi0xj+mWsCPzm2EFACCG5g1IP1x3o
kSJd/s7uZC1TYg9VpA796x761D+p+Nj3wqmmZ1fvRq4Tp5g+jvVuCnEDGltnmioJ+tc92g/FR7Gj
jZRW/vq+oKHOT11Dzr7t6iLWuynELWgrcBrFTROpnlOOIi4odnSRYjnz4XfT8mJzNnUIYryTQtyC
5opXo80iOuyubgcJie/LAmL7P0WR04DPs5ibnl29y3j0t9V7jKvD2b6JEYMUYgM0Vg4abRbRZzfa
6UVIz48t6iQOQ6ZIbFdTpwKFOCK+K6rU9tqlSMo+HVJppuwXTfTNB5PFWk3/jyS2tunv6y8KsQW+
7mTVcjcprzl0D1Kl44MUD+ivI9WYHXIloclirbrvIfnSNv19/UUhtsBX5aCt0vGNlkU7pJtcesUs
w8diWo7b5pBzgUIMgqZKJwQuCmFIn6b0LpRY1FYRo/jNB0NGNkz+tu47aMPUPuHJWj3wmYYU/EMI
IW3U1XNdgq25Xuyq13vdvpQ7ITbCu169qjWINdtOCDEHvZz7rIs4NA2IrwPNNYJeOEkYtMVvjOMj
Y2Nj15AtTrHS77MuohAPBLVQVKGghSNETGiJO1doi1+fjV9UXwzdBTLkBC7tcI6YEEIIPCOh1qgf
vH2JEEIIDH1XUVePw0wJCjEhhJBgmIhpqoLbBIWYEEIIiQiFmBBCCIkIhZgQQgiJSNZCnMpdskPh
LU3EhhTzN5cL6GMQKp0x9xgPJWshtj1izfX7UNB6S1MZrQXQBB9pG/LMFO8sbktTCvuBY/o5VDpH
q6pDXV3o8hncR0xIA4xVQnSBWma5jzhxUHoUKYJYoEk8WNbwKZ/upSm/YIVYkxNjMvRYOWIG/Us4
5aILTQ1pWCHW5EQE6C+/mPg3pUrTZVqGPCsln/Yh9DqWNmK9u897XdeHvtMOK8QpkNNqZF50gNMY
cuGnclqGPm+IX3ze+62RGIvKTN7t0wYXMTAaqi4PWYe4LcqUbIU4REFMYTWyKSGuWkROPxK8RrOb
2GlCFSxXNiBtB2taKFUXA13/74tshTh00KJWZC7til25EX+g5a3LXn+MdCGIpk9i+LZrtKBJjG3+
3xfZCnFoUAue1l67qwKOJC7oIImxyzhDLZspgORb1K1NIhRimIrFFG32+sKVKKCvOkdrcLj0F6LP
kYZU0Z+tkTYx7vKV13zigR76oA8JIWQYZWH1XZ/yQA8DtLUaNYiwNp/mAPMEF+aNP+p8G7IzY5K3
FGLRIWxV0Asu+pBvjviI85TzF2WhUUrEWhhnKsa2q6ZN0mOStxTiEpoqFS0FF6nVqRW0Sx/KDM1f
5HxLqTGJkoYQQ8A2762KcVW0u+x1FSOcIyaEJEEqdUsq6WgCNX1Ndrmwl3PEPUBpPZpCe/0+l+gA
sXLvQ0o98TpQ82nUG65eGBHCXgpxDUj7JU1ADewmfPlXmx9coylmtZLSvDFCvISyoe3UrTKxzvam
EDegTYy1oVk0UeNiiE9R0oRiRxOa47aKy/PEh9oQ63jcaj1fN2ccAs4RE0IIIfJyg8DH7U1tz5zr
9G2EEEKIUtqGpn12IDk0HRHfwzE5XcOoFfq0HvoFg1SO/DSdI24bph7yni4oxIb4WlzkM9C1XuiQ
E/RpPfQLBjHywUe92DZHLNI8JG0rxn39RSE2xFdAssJJh5R6cS7TMuRZKfnUBandodyEq4Vkpn/b
51f+1OUAAAI2SURBVApFl1CIAeGQ8stosj2lRhXKNYMp+dQFMf0R691DeshNB3TUUbeVafTjGwox
IBxSfhnNthM/aGqcETeEaBiavqN64EfTd2ygEAeAFYdb6M+8cVkppxhLKGlCscMlpsPU5VO6TKAQ
B4C9Orf42OOHiAu7UNOGQuxDLTQuArWxI0XazqQuYzOszQM9CCGEeCXVer/riMzy93jpQ4IgtHhN
0GIn6UfK+Zty2kKDepHF0BXZrs6mphArRUvrUoudVdAqDFRQhkF9oDV2kUHzqevrDbmP2AGpVig5
EOoAgBiEPGmoDylcNtGGBhu7SCENJvRJ51DfuBh2pxCXQKp8TcilcJmgLe9s8JE2lAVvGnrUGmzs
IoU0mNAnrvv8Td3RmEPKFIU4IkMLRlfG82AQfFLxqetDO9D8kkJDz4XghAAp75tsKa+Irq6O7tUr
56ppQgghZDhtW5uyXTWN1LIihBCimy5N6dszTlqIU+h5szFhz9TUVGwTVEF/2UF/2ZGSv0zn2m1H
fpMWYhSGiOnVV1/t0JI06PJnSgU/BDn7q0/ZRPcXSuN9ZAe6v3xg2wmkEIv/wE2hZ26LpnuWcwGl
gkYCJZZQtpO5BMWOJlze6DQUCrG0H0tG+oFeCIegNS667lxFAMWO0MQuL7H9HuP9SPV+lFXThBBC
SE60Se3cgHaISPyWHyGEEIIEh6YJIYSQiFCICSGEkIhQiAkhhJCIUIgJIYSQiFCICSGEkIhQiAkh
hJCI/H9cLhFxH6/cDAAAAABJRU5ErkJggg==
"></img>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>There's some interesting structure in this graph!  The blocks along the diagonal
indicate groups of words which are closely related: for instance, "cut", "cot", "cat", "can", "con",
etc. are all near each other in alphabetical order, and share many links: this creates a dark
blob on the diagonal.</p>
<p>We also see line patterns off the diagonal.  These are the result of words which differ by their first
letter: For example "tan" is linked to "can", and "ton" is linked to "con".  Using matplotlib's
interactive plotting functionality and zooming around this graph can be a pretty interesting exercise,
and help you gain intuition into the connections between these words.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h3 class="ipynb">
  Finding the Shortest Path: Dijkstra's Algorithm
</h3>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now let's return to our problem: finding the shortest path from "APE" to "MAN".
This is now a graph optimization problem, in which we hope to find the shortest
path from one node to another along the graph.  A well-known algorithm to
accomplish this task is Dyjkstra's algorithm, which is based on <a href="http://jakevdp.github.com/blog/2012/09/12/dynamic-programming-in-python/">Dynamic Programming</a>
principles.  Dijkstra's algorithm is built into the new <code>csgraph</code> package, and can be used as
follows.</p>
<p>First we need to find the indices of the two words in question:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [8]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">i1</span> <span class="o">=</span> <span class="n">wordlist</span><span class="o">.</span><span class="n">searchsorted</span><span class="p">(</span><span class="s">&#39;ape&#39;</span><span class="p">)</span>
<span class="k">print</span><span class="p">(</span><span class="n">i1</span><span class="p">,</span> <span class="n">wordlist</span><span class="p">[</span><span class="n">i1</span><span class="p">])</span>

<span class="n">i2</span> <span class="o">=</span> <span class="n">wordlist</span><span class="o">.</span><span class="n">searchsorted</span><span class="p">(</span><span class="s">&#39;man&#39;</span><span class="p">)</span>
<span class="k">print</span><span class="p">(</span><span class="n">i2</span><span class="p">,</span> <span class="n">wordlist</span><span class="p">[</span><span class="n">i2</span><span class="p">])</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">(22, &apos;ape&apos;)
(310, &apos;man&apos;)
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Next we'll call the <code>shortest_path</code> function, which calls Dijkstra's algorithm under the hood:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [9]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">distances</span><span class="p">,</span> <span class="n">predecessors</span> <span class="o">=</span> <span class="n">csgraph</span><span class="o">.</span><span class="n">shortest_path</span><span class="p">(</span><span class="n">graph</span><span class="p">,</span> <span class="n">return_predecessors</span><span class="o">=</span><span class="bp">True</span><span class="p">)</span>
<span class="s">&quot;distance from &#39;</span><span class="si">%s</span><span class="s">&#39; to &#39;</span><span class="si">%s</span><span class="s">&#39;: </span><span class="si">%i</span><span class="s"> steps&quot;</span> <span class="o">%</span> <span class="p">(</span><span class="n">wordlist</span><span class="p">[</span><span class="n">i1</span><span class="p">],</span> <span class="n">wordlist</span><span class="p">[</span><span class="n">i2</span><span class="p">],</span> <span class="n">distances</span><span class="p">[</span><span class="n">i1</span><span class="p">,</span> <span class="n">i2</span><span class="p">])</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [9]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">&quot;distance from &apos;ape&apos; to &apos;man&apos;: 5 steps&quot;</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We found a path of length 5 steps!  This is shorter than the seven steps above.
The steps taken are stored in the predecessor list:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [10]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">i</span> <span class="o">=</span> <span class="n">i1</span>
<span class="k">while</span> <span class="n">i</span> <span class="o">!=</span> <span class="n">i2</span><span class="p">:</span>
    <span class="k">print</span><span class="p">(</span><span class="n">wordlist</span><span class="p">[</span><span class="n">i</span><span class="p">])</span>
    <span class="n">i</span> <span class="o">=</span> <span class="n">predecessors</span><span class="p">[</span><span class="n">i2</span><span class="p">,</span> <span class="n">i</span><span class="p">]</span>
<span class="k">print</span><span class="p">(</span><span class="n">wordlist</span><span class="p">[</span><span class="n">i2</span><span class="p">])</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">ape
apt
opt
oat
mat
man
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h3 class="ipynb">
  Finding the Longest Minimal Path
</h3>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Another question we can ask is this: out of all the shortest paths between any two
nodes, what is the longest?  That is, which connected words are maximally separated
in our linguistic space?  To find out, we can use the distances matrix returned by
the algorithm.</p>
<p>If any words have no path between them, the algorithm returns infinity.  We don't care about
the infinities here, so we'll mask them out and ask what the longest distance is:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [11]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">np</span><span class="o">.</span><span class="n">ma</span><span class="o">.</span><span class="n">masked_invalid</span><span class="p">(</span><span class="n">distances</span><span class="p">)</span><span class="o">.</span><span class="n">max</span><span class="p">()</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [11]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">13.0</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Evidently there exist words that cannot be linked in fewer than 13 steps!
Let's see which ones they are:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [12]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">i1</span><span class="p">,</span> <span class="n">i2</span> <span class="o">=</span> <span class="n">np</span><span class="o">.</span><span class="n">where</span><span class="p">(</span><span class="n">distances</span> <span class="o">==</span> <span class="mi">13</span><span class="p">)</span>
<span class="n">unique_paths</span> <span class="o">=</span> <span class="p">(</span><span class="n">i1</span> <span class="o">&lt;</span> <span class="n">i2</span><span class="p">)</span>
<span class="nb">zip</span><span class="p">(</span><span class="n">wordlist</span><span class="p">[</span><span class="n">i1</span><span class="p">][</span><span class="n">unique_paths</span><span class="p">],</span> <span class="n">wordlist</span><span class="p">[</span><span class="n">i2</span><span class="p">][</span><span class="n">unique_paths</span><span class="p">])</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [12]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">[(&apos;imp&apos;, &apos;ohm&apos;), (&apos;imp&apos;, &apos;ohs&apos;), (&apos;ohm&apos;, &apos;ump&apos;), (&apos;ohs&apos;, &apos;ump&apos;)]</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We have four pairs of words, and examining them, we see that the paths go from
one pair, "imp" and "ump", to another pair, "ohm" and "ohs".  We'll use the same
trick as above to list the links between two of these:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [13]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">i</span> <span class="o">=</span> <span class="n">i2</span><span class="p">[</span><span class="mi">0</span><span class="p">]</span>
<span class="k">while</span> <span class="n">i</span> <span class="o">!=</span> <span class="n">i1</span><span class="p">[</span><span class="mi">0</span><span class="p">]:</span>
    <span class="k">print</span><span class="p">(</span><span class="n">wordlist</span><span class="p">[</span><span class="n">i</span><span class="p">])</span>
    <span class="n">i</span> <span class="o">=</span> <span class="n">predecessors</span><span class="p">[</span><span class="n">i1</span><span class="p">[</span><span class="mi">0</span><span class="p">],</span> <span class="n">i</span><span class="p">]</span>
<span class="k">print</span><span class="p">(</span><span class="n">wordlist</span><span class="p">[</span><span class="n">i</span><span class="p">])</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">ohm
oho
tho
too
moo
mod
mid
aid
add
ads
ass
asp
amp
imp
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h3 class="ipynb">
  Connected Components
</h3>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Finally, we can ask about connected components of the graph.  There are likely
"islands" in the word graph which can't be reached from the majority of words,
and we'd like to see what these are.  To do this, we can use the <code>connected_componets</code>
routine:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [14]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">n_components</span><span class="p">,</span> <span class="n">component_list</span> <span class="o">=</span> <span class="n">csgraph</span><span class="o">.</span><span class="n">connected_components</span><span class="p">(</span><span class="n">graph</span><span class="p">)</span>
<span class="n">n_components</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [14]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">14</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This shows us that we have 14 distinct components: 14 islands of words with no paths between them.
Let's see how big these islands are:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [15]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="p">[</span><span class="n">np</span><span class="o">.</span><span class="n">sum</span><span class="p">(</span><span class="n">component_list</span> <span class="o">==</span> <span class="n">i</span><span class="p">)</span> <span class="k">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">14</span><span class="p">)]</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [15]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">[571, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1]</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We see that the bulk of three letter words are connected: the main set of 571 has
paths to all others in that set.  The interesting words are the ones all by
themselves:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [16]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="p">[</span><span class="nb">list</span><span class="p">(</span><span class="n">wordlist</span><span class="p">[</span><span class="n">np</span><span class="o">.</span><span class="n">where</span><span class="p">(</span><span class="n">component_list</span> <span class="o">==</span> <span class="n">i</span><span class="p">)])</span> <span class="k">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">1</span><span class="p">,</span> <span class="mi">14</span><span class="p">)]</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [16]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">[[&apos;aha&apos;],
 [&apos;chi&apos;],
 [&apos;ebb&apos;],
 [&apos;ems&apos;, &apos;emu&apos;],
 [&apos;gnu&apos;],
 [&apos;ism&apos;],
 [&apos;nth&apos;],
 [&apos;ova&apos;],
 [&apos;qua&apos;],
 [&apos;ugh&apos;],
 [&apos;ups&apos;],
 [&apos;urn&apos;],
 [&apos;use&apos;]]</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>These are all the three-letter "loner" words, which can't reach any other valid
words through the changing of a single letter.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h3 class="ipynb">
  More: Minimum Spanning Tree, Depth-first search, Breadth-first search...
</h3>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>There's much more we could do from here.  We could use the Minimum Spanning Tree
algorithm to do hierarchical clustering of the words.  We could create a depth-first
or breadth-first tree.  We could repeat everything above on words of length 4 or
length 5...  if you feel inclined, check out <code>scipy.sparse.csgraph</code> in <strong>scipy v. 0.11</strong>!</p>
<p>This post was written entirely in an IPython Notebook: the notebook file is available for download here:
<a href="http://jakevdp.github.com/downloads/notebooks/sparse-graph.ipynb">sparse-graph.ipynb</a>.
For more information on blogging with notebooks in octopress, see my
<a href="http://jakevdp.github.com/blog/2012/10/04/blogging-with-ipython/">previous post</a> on the subject.</p>
<p>Oh, and one challenge for all the over-achievers out there: how many steps does it take
to get from "Guido" to "Python" using English language words?
First to give the answer wins... well, nothing, actually.
What can I say.  I do this for free.</p>
<p>Happy coding!</p>
</div>

</div>