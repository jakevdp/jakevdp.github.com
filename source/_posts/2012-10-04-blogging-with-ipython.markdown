---
layout: post
title: "Blogging with IPython in Octopress"
date: 2012-10-04 18:40
comments: true
categories: 
---

<div class="ipynb">

<div class="text_cell_render border-box-sizing rendered_html">
<p>A few weeks ago, Fernando Perez, the creator of IPython, wrote a <a href="http://blog.fperez.org/2012/09/blogging-with-ipython-notebook.html">post</a> about blogging with IPython notebooks.  I decided to take a stab at making this work in Octopress.</p>
<p>I started by following Fernando's outline:  Go to <a href="http://github.com/ipython/nbconvert">http://github.com/ipython/nbconvert</a> and getting the current version of the notebook converter.  Running <code>nbconvert.py -f blogger-html filename.ipynb</code> will give you a separate html and header file with the notebook content.  I inserted the stylesheet info into my header (in octopress, the default location is <code>source/_includes/custom/head.html</code>) and copied the html directly into my post.</p>
<p>I immediately encountered a problem.  <code>nbconvert</code> uses global CSS classes and style markups, and some of these (notably the "hightlight" class and the <code>&lt;pre&gt;</code> tag formatting) conflict with styles defined in my octopress theme.  The result was that every post in my blog ended up looking like an ugly hybrid of octopress and an ipython notebook.  Not very nice.</p>
<p>So I did some surgery.  Admittedly, this is a terrible hack, but the following code takes the files output by nbconvert, slices them up, and creates a specific set of CSS classes for the notebook markup, such that there's no longer a conflict with the native octopress styles
(you can download this script <a href="http://jakevdp.github.com/downloads/code/convert_notebook.py">here</a>):</p>
</div>
<!-- more -->
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [&nbsp;]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="c">#!/usr/bin/python</span>
<span class="kn">import</span> <span class="nn">os</span>
<span class="kn">import</span> <span class="nn">sys</span>

<span class="k">try</span><span class="p">:</span>
    <span class="n">nbconvert</span> <span class="o">=</span> <span class="n">sys</span><span class="o">.</span><span class="n">argv</span><span class="p">[</span><span class="mi">1</span><span class="p">]</span>
    <span class="n">notebook</span> <span class="o">=</span> <span class="n">sys</span><span class="o">.</span><span class="n">argv</span><span class="p">[</span><span class="mi">2</span><span class="p">]</span>
<span class="k">except</span><span class="p">:</span>
    <span class="k">print</span> <span class="s">&quot;usage: python octopress_notebook.py  /path/to/nbconvert.py  /path/to/notebook_file.ipynb&quot;</span>
    <span class="n">sys</span><span class="o">.</span><span class="n">exit</span><span class="p">(</span><span class="o">-</span><span class="mi">1</span><span class="p">)</span>

<span class="c"># convert notebook</span>
<span class="n">os</span><span class="o">.</span><span class="n">system</span><span class="p">(</span><span class="s">&#39;</span><span class="si">%s</span><span class="s"> -f blogger-html </span><span class="si">%s</span><span class="s">&#39;</span> <span class="o">%</span> <span class="p">(</span><span class="n">nbconvert</span><span class="p">,</span> <span class="n">notebook</span><span class="p">))</span>

<span class="c"># get out filenames</span>
<span class="n">outfile_root</span> <span class="o">=</span> <span class="n">os</span><span class="o">.</span><span class="n">path</span><span class="o">.</span><span class="n">splitext</span><span class="p">(</span><span class="n">notebook</span><span class="p">)[</span><span class="mi">0</span><span class="p">]</span>
<span class="n">body_file</span> <span class="o">=</span> <span class="n">outfile_root</span> <span class="o">+</span> <span class="s">&#39;.html&#39;</span>
<span class="n">header_file</span> <span class="o">=</span> <span class="n">outfile_root</span> <span class="o">+</span> <span class="s">&#39;_header.html&#39;</span>


<span class="c"># read the files</span>
<span class="n">body</span> <span class="o">=</span> <span class="nb">open</span><span class="p">(</span><span class="n">body_file</span><span class="p">)</span><span class="o">.</span><span class="n">read</span><span class="p">()</span>
<span class="n">header</span> <span class="o">=</span> <span class="nb">open</span><span class="p">(</span><span class="n">header_file</span><span class="p">)</span><span class="o">.</span><span class="n">read</span><span class="p">()</span>


<span class="c"># replace the highlight tags</span>
<span class="n">body</span> <span class="o">=</span> <span class="n">body</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;class=&quot;highlight&quot;&#39;</span><span class="p">,</span> <span class="s">&#39;class=&quot;highlight-ipynb&quot;&#39;</span><span class="p">)</span>
<span class="n">header</span> <span class="o">=</span> <span class="n">header</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;highlight&#39;</span><span class="p">,</span> <span class="s">&#39;highlight-ipynb&#39;</span><span class="p">)</span>


<span class="c"># specify &lt;pre&gt; tags</span>
<span class="n">body</span> <span class="o">=</span> <span class="n">body</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;&lt;pre&#39;</span><span class="p">,</span> <span class="s">&#39;&lt;pre class=&quot;ipynb&quot;&#39;</span><span class="p">)</span>
<span class="n">header</span> <span class="o">=</span> <span class="n">header</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;html, body&#39;</span><span class="p">,</span> <span class="s">&#39;</span><span class="se">\n</span><span class="s">&#39;</span><span class="o">.</span><span class="n">join</span><span class="p">((</span><span class="s">&#39;pre.ipynb {&#39;</span><span class="p">,</span>
                                                 <span class="s">&#39;  color: black;&#39;</span><span class="p">,</span>
                                                 <span class="s">&#39;  background: #f7f7f7;&#39;</span><span class="p">,</span>
                                                 <span class="s">&#39;  border: 0;&#39;</span><span class="p">,</span>
                                                 <span class="s">&#39;  box-shadow: none;&#39;</span><span class="p">,</span>
                                                 <span class="s">&#39;  margin-bottom: 0;&#39;</span><span class="p">,</span>
                                                 <span class="s">&#39;  padding: 0;&#39;</span>
                                                 <span class="s">&#39;}</span><span class="se">\n</span><span class="s">&#39;</span><span class="p">,</span>
                                                 <span class="s">&#39;html, body&#39;</span><span class="p">)))</span>


<span class="c"># create a special div for notebook</span>
<span class="n">body</span> <span class="o">=</span> <span class="s">&#39;&lt;div class=&quot;ipynb&quot;&gt;</span><span class="se">\n\n</span><span class="s">&#39;</span> <span class="o">+</span> <span class="n">body</span> <span class="o">+</span> <span class="s">&quot;</span><span class="se">\n\n</span><span class="s">&lt;/div&gt;&quot;</span>
<span class="n">header</span> <span class="o">=</span> <span class="n">header</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;body {&#39;</span><span class="p">,</span> <span class="s">&#39;div.ipynb {&#39;</span><span class="p">)</span>


<span class="c"># specialize headers</span>
<span class="n">header</span> <span class="o">=</span> <span class="n">header</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;html, body,&#39;</span><span class="p">,</span>
                        <span class="s">&#39;</span><span class="se">\n</span><span class="s">&#39;</span><span class="o">.</span><span class="n">join</span><span class="p">(((</span><span class="s">&#39;h1.ipynb h2.ipynb h3.ipynb &#39;</span>
                                    <span class="s">&#39;h4.ipynb h5.ipynb h6.ipynb {&#39;</span><span class="p">),</span>
                                   <span class="s">&#39;h1.ipynb h2.ipynb ... {&#39;</span><span class="p">,</span>
                                   <span class="s">&#39;  margin: 0;&#39;</span><span class="p">,</span>
                                   <span class="s">&#39;  padding: 0;&#39;</span><span class="p">,</span>
                                   <span class="s">&#39;  border: 0;&#39;</span><span class="p">,</span>
                                   <span class="s">&#39;  font-size: 100%;&#39;</span><span class="p">,</span>
                                   <span class="s">&#39;  font: inherit;&#39;</span><span class="p">,</span>
                                   <span class="s">&#39;  vertical-align: baseline;&#39;</span><span class="p">,</span>
                                   <span class="s">&#39;}</span><span class="se">\n</span><span class="s">&#39;</span><span class="p">,</span>
                                   <span class="s">&#39;html, body,&#39;</span><span class="p">)))</span>
<span class="k">for</span> <span class="n">h</span> <span class="ow">in</span> <span class="s">&#39;123456&#39;</span><span class="p">:</span>
    <span class="n">body</span> <span class="o">=</span> <span class="n">body</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;&lt;h</span><span class="si">%s</span><span class="s">&#39;</span> <span class="o">%</span> <span class="n">h</span><span class="p">,</span> <span class="s">&#39;&lt;h</span><span class="si">%s</span><span class="s"> class=&quot;ipynb&quot;&#39;</span> <span class="o">%</span> <span class="n">h</span><span class="p">)</span>


<span class="c"># comment out document-level formatting</span>
<span class="n">header</span> <span class="o">=</span> <span class="n">header</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;html, body,&#39;</span><span class="p">,</span>
                        <span class="s">&#39;/*html, body,*/&#39;</span><span class="p">)</span>
<span class="n">header</span> <span class="o">=</span> <span class="n">header</span><span class="o">.</span><span class="n">replace</span><span class="p">(</span><span class="s">&#39;h1, h2, h3, h4, h5, h6,&#39;</span><span class="p">,</span>
                        <span class="s">&#39;/*h1, h2, h3, h4, h5, h6,*/&#39;</span><span class="p">)</span>

<span class="c">#----------------------------------------------------------------------</span>
<span class="c"># Write the results to file</span>
<span class="nb">open</span><span class="p">(</span><span class="n">body_file</span><span class="p">,</span> <span class="s">&#39;w&#39;</span><span class="p">)</span><span class="o">.</span><span class="n">write</span><span class="p">(</span><span class="n">body</span><span class="p">)</span>
<span class="nb">open</span><span class="p">(</span><span class="n">header_file</span><span class="p">,</span> <span class="s">&#39;w&#39;</span><span class="p">)</span><span class="o">.</span><span class="n">write</span><span class="p">(</span><span class="n">header</span><span class="p">)</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This code should be run with two arguments: first the file to be converted, then the path to <code>nbconvert.py</code>.  Like the native <code>nbconvert.py</code> this produces a separate file of header code (which is inserted once into the  master blog header) and body code which can be copied verbatim into the post.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Trying it out
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>If you haven't noticed already, this post is written entirely in an IPython notebook.  So let's see how some things look.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>First of all, we can write some math, which is rendered using mathjax:</p>
<p>$f(x) = \int_0^\infty \left(\frac{\sin(x)}{x^2}\right)dx$</p>
<p>As we see, it renders nicely.</p>
<p>Or we can do some inline plotting:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [1]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="o">%</span><span class="k">pylab</span> <span class="n">inline</span>
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
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [2]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="kn">import</span> <span class="nn">numpy</span> <span class="kn">as</span> <span class="nn">np</span>
<span class="n">x</span> <span class="o">=</span> <span class="n">np</span><span class="o">.</span><span class="n">linspace</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span> <span class="mi">10</span><span class="p">,</span> <span class="mi">100</span><span class="p">)</span>
<span class="n">pylab</span><span class="o">.</span><span class="n">plot</span><span class="p">(</span><span class="n">x</span><span class="p">,</span> <span class="n">np</span><span class="o">.</span><span class="n">sin</span><span class="p">(</span><span class="n">x</span><span class="p">))</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [2]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">[&lt;matplotlib.lines.Line2D at 0x2cdba90&gt;]</pre>
</div>
</div>
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_display_data">
<img src="data:image/png;base64,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
oAAAAABJRU5ErkJggg==
"></img>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>You can do pretty much anything else a notebook does as well.  The IPython team did the hard part.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Where to go from here?
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>There's clearly a cleaner way to do this.  If the IPython team would be open to the idea, I think their HTML stylesheets should be modified so that notebooks can be embedded within any CSS framework with as few conflicts as possible.  This means getting rid of all top-level formatting in the style-sheets, and removing potentially common class names like "highlight".  Once this is done, <code>nbconvert.py</code> could output this directly, obviating the need for my unforgivable hack shown above.</p>
<p>Second, I'd love to build notebook support directly into octopress.  If <code>nbconvert.py</code> is available on the user's system, it could be called directly from the Ruby script that generates Octopress HTML.  I have about as much experience with Ruby as I do with Swahili (read: None) so this would take some work for me.  I'd be happy to pass the baton to any Octopress gurus out there...</p>
<p>Either of those options will smooth out the notebook/blogging combo considerably, and give me the potential to prognosticate Python in perpetuum.
By the way, the notebook used to generate this page can be downloaded <a href="http://jakevdp.github.com/downloads/notebooks/nb_in_octopress.ipynb">here</a>.  Happy coding!</p>
</div>

</div>