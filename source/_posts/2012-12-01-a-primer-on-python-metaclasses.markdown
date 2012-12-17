---
layout: post
title: "A Primer on Python Metaclasses"
date: 2012-12-01 07:25
comments: true
categories: 
---
<div class="ipynb">

<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Python, Classes, and Objects
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Most readers are aware that Python is an object-oriented language.  By
object-oriented, we mean that Python can define <em>classes</em>, which bundle
<strong>data</strong> and <strong>functionality</strong> into one entity.  For example, we may
create a class <code>IntContainer</code> which stores an integer and allows
certain operations to be performed:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [1]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">IntContainer</span><span class="p">(</span><span class="nb">object</span><span class="p">):</span>
    <span class="k">def</span> <span class="nf">__init__</span><span class="p">(</span><span class="bp">self</span><span class="p">,</span> <span class="n">i</span><span class="p">):</span>
        <span class="bp">self</span><span class="o">.</span><span class="n">i</span> <span class="o">=</span> <span class="nb">int</span><span class="p">(</span><span class="n">i</span><span class="p">)</span>

    <span class="k">def</span> <span class="nf">add_one</span><span class="p">(</span><span class="bp">self</span><span class="p">):</span>
        <span class="bp">self</span><span class="o">.</span><span class="n">i</span> <span class="o">+=</span> <span class="mi">1</span>
</pre></div>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [2]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">ic</span> <span class="o">=</span> <span class="n">IntContainer</span><span class="p">(</span><span class="mi">2</span><span class="p">)</span>
<span class="n">ic</span><span class="o">.</span><span class="n">add_one</span><span class="p">()</span>
<span class="k">print</span><span class="p">(</span><span class="n">ic</span><span class="o">.</span><span class="n">i</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">3
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This is a bit of a silly example, but shows the fundamental nature of
classes: their ability to bundle data and operations into a single
<em>object</em>, which leads to cleaner, more manageable, and more adaptable code.
Additionally, classes can inherit properties from parents and add or
specialize attributes and methods.  This <em>object-oriented</em>
approach to programming can be very intuitive and powerful.</p>
<p>What many do not realize, though, is that quite literally
<a href="http://www.diveintopython.net/getting_to_know_python/everything_is_an_object.html"><em>everything</em></a>
in the Python language is an object.</p>

<!-- more -->

<p>For example, integers are simply instances of
the built-in <code>int</code> type:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [3]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">print</span> <span class="nb">type</span><span class="p">(</span><span class="mi">1</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">&lt;type &apos;int&apos;&gt;
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>To emphasize that the <code>int</code> type really is an object, let's derive from it
and specialize the <code>__add__</code> method (which is the machinery underneath
the <code>+</code> operator):</p>
<p><em>(Note: We'll used the</em> <code>super</code> <em>syntax to call methods from the parent class: if you're unfamiliar with this, take a look at</em>
<a href="http://stackoverflow.com/questions/576169/understanding-python-super-and-init-methods"><em>this StackOverflow question</em></a><em>).</em></p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [4]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">MyInt</span><span class="p">(</span><span class="nb">int</span><span class="p">):</span>
    <span class="k">def</span> <span class="nf">__add__</span><span class="p">(</span><span class="bp">self</span><span class="p">,</span> <span class="n">other</span><span class="p">):</span>
        <span class="k">print</span> <span class="s">&quot;specializing addition&quot;</span>
        <span class="k">return</span> <span class="nb">super</span><span class="p">(</span><span class="n">MyInt</span><span class="p">,</span> <span class="bp">self</span><span class="p">)</span><span class="o">.</span><span class="n">__add__</span><span class="p">(</span><span class="n">other</span><span class="p">)</span>

<span class="n">i</span> <span class="o">=</span> <span class="n">MyInt</span><span class="p">(</span><span class="mi">2</span><span class="p">)</span>
<span class="k">print</span><span class="p">(</span><span class="n">i</span> <span class="o">+</span> <span class="mi">2</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">specializing addition
4
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Using the <code>+</code> operator on our derived type goes through our <code>__add__</code>
method, as expected.
We see that <code>int</code> really is an object that can be subclassed and extended
just like user-defined classes.  The same is true
of <code>float</code>s, <code>list</code>s, <code>tuple</code>s, and everything else in the Python
language.  They're all objects.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Down the Rabbit Hole: Classes as Objects
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We said above that <em>everything</em> in python is an object: it turns out that this
is true of <em>classes themselves</em>.  Let's look at an example.</p>
<p>We'll start by defining a class that does nothing</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [5]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">DoNothing</span><span class="p">(</span><span class="nb">object</span><span class="p">):</span>
    <span class="k">pass</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>If we instantiate this, we can use the <code>type</code> operator to see the type
of object that it is:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [6]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">d</span> <span class="o">=</span> <span class="n">DoNothing</span><span class="p">()</span>
<span class="nb">type</span><span class="p">(</span><span class="n">d</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [6]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">__main__.DoNothing</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>We see that our variable <code>d</code> is an instance of the class
<code>__main__.DoNothing</code>.</p>
<p>We can do this similarly for built-in  types:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [7]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">L</span> <span class="o">=</span> <span class="p">[</span><span class="mi">1</span><span class="p">,</span> <span class="mi">2</span><span class="p">,</span> <span class="mi">3</span><span class="p">]</span>
<span class="nb">type</span><span class="p">(</span><span class="n">L</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [7]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">list</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>A list is, as you may expect, an object of type <code>list</code>.</p>
<p>But let's take this a step further: what is the type
of <code>DoNothing</code> itself?</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [8]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="nb">type</span><span class="p">(</span><span class="n">DoNothing</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [8]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">type</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>The type of <code>DoNothing</code> is <code>type</code>.  This tells us that the <em>class</em>
<code>DoNothing</code> is itself an object, and that object is of type <code>type</code>.</p>
<p>It turns out that this is the same for built-in datatypes:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [9]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="nb">type</span><span class="p">(</span><span class="nb">tuple</span><span class="p">),</span> <span class="nb">type</span><span class="p">(</span><span class="nb">list</span><span class="p">),</span> <span class="nb">type</span><span class="p">(</span><span class="nb">int</span><span class="p">),</span> <span class="nb">type</span><span class="p">(</span><span class="nb">float</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [9]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">(type, type, type, type)</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>What this shows is that in Python, <em>classes are objects</em>, and they are objects of
type <code>type</code>.  <code>type</code> is a <em>metaclass</em>: a class which instantiates classes.
All <a href="http://www.python.org/doc/newstyle/">new-style classes</a>
in Python are instances of the <code>type</code> metaclass, including <code>type</code> itself:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [10]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="nb">type</span><span class="p">(</span><span class="nb">type</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [10]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">type</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Yes, you read that correctly:
the type of <code>type</code> is <code>type</code>.  In other words, <code>type</code> is <em>an
instance of itself</em>.  This sort of circularity cannot (to my knowledge)
be duplicated in pure Python, and the behavior is created through a bit of a
hack at the implementation level of Python.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Metaprogramming: Creating Classes on the Fly
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now that we've stepped back and considered the fact that classes in Python
are simply objects like everything else, we can think about what is known
as <em>metaprogramming</em>.  You're probably used to creating functions which
return objects.  We can think of these functions as an object factory: they
take some arguments, create an object, and return it.  Here is a simple example
of a function which creates an <code>int</code> object:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [11]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">int_factory</span><span class="p">(</span><span class="n">s</span><span class="p">):</span>
    <span class="n">i</span> <span class="o">=</span> <span class="nb">int</span><span class="p">(</span><span class="n">s</span><span class="p">)</span>
    <span class="k">return</span> <span class="n">i</span>

<span class="n">i</span> <span class="o">=</span> <span class="n">int_factory</span><span class="p">(</span><span class="s">&#39;100&#39;</span><span class="p">)</span>
<span class="k">print</span><span class="p">(</span><span class="n">i</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">100
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This is overly-simplistic, but any function you write in the course
of a normal program can be boiled down to this: take some arguments,
do some operations, and create &amp; return an object.
With the above discussion in mind, though, there's nothing to stop
us from creating an object of type <code>type</code> (that is, a class), 
and returning that instead -- this is a <em>metafunction:</em></p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [12]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">class_factory</span><span class="p">():</span>
    <span class="k">class</span> <span class="nc">Foo</span><span class="p">(</span><span class="nb">object</span><span class="p">):</span>
        <span class="k">pass</span>
    <span class="k">return</span> <span class="n">Foo</span>

<span class="n">F</span> <span class="o">=</span> <span class="n">class_factory</span><span class="p">()</span>
<span class="n">f</span> <span class="o">=</span> <span class="n">F</span><span class="p">()</span>
<span class="k">print</span><span class="p">(</span><span class="nb">type</span><span class="p">(</span><span class="n">f</span><span class="p">))</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">&lt;class &apos;__main__.Foo&apos;&gt;
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Just as the function <code>int_factory</code> constructs an returns an instance of
<code>int</code>,
the function <code>class_factory</code> constructs and returns an instance of <code>type</code>:
that is, a class.</p>
<p>But the above construction is a bit awkward: especially if we were going to do some
more complicated logic when constructing <code>Foo</code>, it would be nice to avoid all the
nested indentations and define the class in a more dynamic way.
We can accomplish this by instantiating <code>Foo</code> from <code>type</code> directly:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [13]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">def</span> <span class="nf">class_factory</span><span class="p">():</span>
    <span class="k">return</span> <span class="nb">type</span><span class="p">(</span><span class="s">&#39;Foo&#39;</span><span class="p">,</span> <span class="p">(),</span> <span class="p">{})</span>

<span class="n">F</span> <span class="o">=</span> <span class="n">class_factory</span><span class="p">()</span>
<span class="n">f</span> <span class="o">=</span> <span class="n">F</span><span class="p">()</span>
<span class="k">print</span><span class="p">(</span><span class="nb">type</span><span class="p">(</span><span class="n">f</span><span class="p">))</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">&lt;class &apos;__main__.Foo&apos;&gt;
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>In fact, the construct</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [14]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">MyClass</span><span class="p">(</span><span class="nb">object</span><span class="p">):</span>
    <span class="k">pass</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>is identical to the construct</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [15]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">MyClass</span> <span class="o">=</span> <span class="nb">type</span><span class="p">(</span><span class="s">&#39;MyClass&#39;</span><span class="p">,</span> <span class="p">(),</span> <span class="p">{})</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p><code>MyClass</code> is an instance of type <code>type</code>, and that can be seen
explicitly in the second version of the definition.
A potential confusion arises from the more common use of <code>type</code> as
a function to determine the type of an object, but you should strive
to separate these two uses of the keyword in your mind:
here <code>type</code> is a class (more precisely, a <em>metaclass</em>),
and <code>MyClass</code> is an instance of <code>type</code>.</p>
<p>The arguments to the <code>type</code> constructor are:</p>
</div>
type(name, bases, dct)
<div class="text_cell_render border-box-sizing rendered_html">
<ul>
<li><code>name</code> is a string giving the name of the class to be constructed</li>
<li><code>bases</code> is a tuple giving the parent classes of the class to be constructed</li>
<li><code>dct</code> is a dictionary of the attributes and methods of the class to be constructed</li>
</ul>
<p>So, for example, the following two pieces of code have identical results:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [16]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">Foo</span><span class="p">(</span><span class="nb">object</span><span class="p">):</span>
    <span class="n">i</span> <span class="o">=</span> <span class="mi">4</span>

<span class="k">class</span> <span class="nc">Bar</span><span class="p">(</span><span class="n">Foo</span><span class="p">):</span>
    <span class="k">def</span> <span class="nf">get_i</span><span class="p">(</span><span class="bp">self</span><span class="p">):</span>
        <span class="k">return</span> <span class="bp">self</span><span class="o">.</span><span class="n">i</span>
    
<span class="n">b</span> <span class="o">=</span> <span class="n">Bar</span><span class="p">()</span>
<span class="k">print</span><span class="p">(</span><span class="n">b</span><span class="o">.</span><span class="n">get_i</span><span class="p">())</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">4
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [17]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">Foo</span> <span class="o">=</span> <span class="nb">type</span><span class="p">(</span><span class="s">&#39;Foo&#39;</span><span class="p">,</span> <span class="p">(),</span> <span class="nb">dict</span><span class="p">(</span><span class="n">i</span><span class="o">=</span><span class="mi">4</span><span class="p">))</span>

<span class="n">Bar</span> <span class="o">=</span> <span class="nb">type</span><span class="p">(</span><span class="s">&#39;Bar&#39;</span><span class="p">,</span> <span class="p">(</span><span class="n">Foo</span><span class="p">,),</span> <span class="nb">dict</span><span class="p">(</span><span class="n">get_i</span> <span class="o">=</span> <span class="k">lambda</span> <span class="bp">self</span><span class="p">:</span> <span class="bp">self</span><span class="o">.</span><span class="n">i</span><span class="p">))</span>

<span class="n">b</span> <span class="o">=</span> <span class="n">Bar</span><span class="p">()</span>
<span class="k">print</span><span class="p">(</span><span class="n">b</span><span class="o">.</span><span class="n">get_i</span><span class="p">())</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">4
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This perhaps seems a bit over-complicated in the case of this contrived
example, but it can be very powerful as a means of dynamically creating
new classes on-the-fly.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Making Things Interesting: Custom Metaclasses
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now things get really fun.  Just as we can inherit from and extend a class we've
created, we can also inherit from and extend the <code>type</code> metaclass, and create
custom behavior in our metaclass.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h3 class="ipynb">
  Example 1: Modifying Attributes
</h3>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's use a simple example where we want to create an API in which the user can
create a set of interfaces which contain a file object.  Each interface should
have a unique string ID, and contain an open file object.  The user could then write
specialized methods to accomplish certain tasks.  There are certainly good
ways to do this without delving into metaclasses, but such a simple example will
(hopefully) elucidate what's going on.</p>
<p>First we'll create our interface meta class, deriving from <code>type</code>:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [18]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">InterfaceMeta</span><span class="p">(</span><span class="nb">type</span><span class="p">):</span>
    <span class="k">def</span> <span class="nf">__new__</span><span class="p">(</span><span class="n">cls</span><span class="p">,</span> <span class="n">name</span><span class="p">,</span> <span class="n">parents</span><span class="p">,</span> <span class="n">dct</span><span class="p">):</span>
        <span class="c"># create a class_id if it&#39;s not specified</span>
        <span class="k">if</span> <span class="s">&#39;class_id&#39;</span> <span class="ow">not</span> <span class="ow">in</span> <span class="n">dct</span><span class="p">:</span>
            <span class="n">dct</span><span class="p">[</span><span class="s">&#39;class_id&#39;</span><span class="p">]</span> <span class="o">=</span> <span class="n">name</span><span class="o">.</span><span class="n">lower</span><span class="p">()</span>
        
        <span class="c"># open the specified file for writing</span>
        <span class="k">if</span> <span class="s">&#39;file&#39;</span> <span class="ow">in</span> <span class="n">dct</span><span class="p">:</span>
            <span class="n">filename</span> <span class="o">=</span> <span class="n">dct</span><span class="p">[</span><span class="s">&#39;file&#39;</span><span class="p">]</span>
            <span class="n">dct</span><span class="p">[</span><span class="s">&#39;file&#39;</span><span class="p">]</span> <span class="o">=</span> <span class="nb">open</span><span class="p">(</span><span class="n">filename</span><span class="p">,</span> <span class="s">&#39;w&#39;</span><span class="p">)</span>
        
        <span class="c"># we need to call type.__new__ to complete the initialization</span>
        <span class="k">return</span> <span class="nb">super</span><span class="p">(</span><span class="n">InterfaceMeta</span><span class="p">,</span> <span class="n">cls</span><span class="p">)</span><span class="o">.</span><span class="n">__new__</span><span class="p">(</span><span class="n">cls</span><span class="p">,</span> <span class="n">name</span><span class="p">,</span> <span class="n">parents</span><span class="p">,</span> <span class="n">dct</span><span class="p">)</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Notice that we've modified the input dictionary (the attributes and
methods of the class) to add a class id if it's not present, and to
replace the filename with a file object pointing to that file name.</p>
<p>Now we'll use our <code>InterfaceMeta</code> class to construct and instantiate
an Interface object:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [19]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="n">Interface</span> <span class="o">=</span> <span class="n">InterfaceMeta</span><span class="p">(</span><span class="s">&#39;Interface&#39;</span><span class="p">,</span> <span class="p">(),</span> <span class="nb">dict</span><span class="p">(</span><span class="nb">file</span><span class="o">=</span><span class="s">&#39;tmp.txt&#39;</span><span class="p">))</span>

<span class="k">print</span><span class="p">(</span><span class="n">Interface</span><span class="o">.</span><span class="n">class_id</span><span class="p">)</span>
<span class="k">print</span><span class="p">(</span><span class="n">Interface</span><span class="o">.</span><span class="n">file</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">interface
&lt;open file &apos;tmp.txt&apos;, mode &apos;w&apos; at 0x2c80810&gt;
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This behaves as we'd expect: the <code>class_id</code> class variable is created,
and the <code>file</code> class variable is replaced with an open file object.
Still, the creation of the <code>Interface</code> class
using <code>InterfaceMeta</code> directly is a bit clunky and difficult to read.
This is where <code>__metaclass__</code> comes in
and steals the show.  We can accomplish the same thing by
defining <code>Interface</code> this way:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [20]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">Interface</span><span class="p">(</span><span class="nb">object</span><span class="p">):</span>
    <span class="n">__metaclass__</span> <span class="o">=</span> <span class="n">InterfaceMeta</span>
    <span class="nb">file</span> <span class="o">=</span> <span class="s">&#39;tmp.txt&#39;</span>
    
<span class="k">print</span><span class="p">(</span><span class="n">Interface</span><span class="o">.</span><span class="n">class_id</span><span class="p">)</span>
<span class="k">print</span><span class="p">(</span><span class="n">Interface</span><span class="o">.</span><span class="n">file</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">interface
&lt;open file &apos;tmp.txt&apos;, mode &apos;w&apos; at 0x2c80ae0&gt;
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>by defining the <code>__metaclass__</code> attribute of the class, we've told the
class that it should be constructed using <code>InterfaceMeta</code> rather than
using <code>type</code>.  To make this more definite, observe that the type of
<code>Interface</code> is now <code>InterfaceMeta</code>:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [21]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="nb">type</span><span class="p">(</span><span class="n">Interface</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt">Out [21]:</div>
<div class="output_subarea output_pyout">
<pre class="ipynb">__main__.InterfaceMeta</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Furthermore, any class derived from <code>Interface</code> will now be constructed
using the same metaclass:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [22]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">UserInterface</span><span class="p">(</span><span class="n">Interface</span><span class="p">):</span>
    <span class="nb">file</span> <span class="o">=</span> <span class="s">&#39;foo.txt&#39;</span>
    
<span class="k">print</span><span class="p">(</span><span class="n">UserInterface</span><span class="o">.</span><span class="n">file</span><span class="p">)</span>
<span class="k">print</span><span class="p">(</span><span class="n">UserInterface</span><span class="o">.</span><span class="n">class_id</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">&lt;open file &apos;foo.txt&apos;, mode &apos;w&apos; at 0x2c80c00&gt;
userinterface
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This simple example shows how metaclasses can be used to create powerful and
flexible APIs for projects.  For example, the
<a href="https://www.djangoproject.com/">Django project</a>
makes use of these sorts of constructions to allow concise declarations
of very powerful extensions to their basic classes.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h3 class="ipynb">
  Example 2: Registering Subclasses
</h3>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Another possible use of a metaclass is to automatically register all
subclasses derived from a given base class.  For example, you may have
a basic interface to a database and wish for the user to be able to
define their own interfaces, which are automatically stored in a master registry.</p>
<p>You might proceed this way:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [23]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">DBInterfaceMeta</span><span class="p">(</span><span class="nb">type</span><span class="p">):</span>
    <span class="c"># we use __init__ rather than __new__ here because we want</span>
    <span class="c"># to modify attributes of the class *after* they have been</span>
    <span class="c"># created</span>
    <span class="k">def</span> <span class="nf">__init__</span><span class="p">(</span><span class="n">cls</span><span class="p">,</span> <span class="n">name</span><span class="p">,</span> <span class="n">bases</span><span class="p">,</span> <span class="n">dct</span><span class="p">):</span>
        <span class="k">if</span> <span class="ow">not</span> <span class="nb">hasattr</span><span class="p">(</span><span class="n">cls</span><span class="p">,</span> <span class="s">&#39;registry&#39;</span><span class="p">):</span>
            <span class="c"># this is the base class.  Create an empty registry</span>
            <span class="n">cls</span><span class="o">.</span><span class="n">registry</span> <span class="o">=</span> <span class="p">{}</span>
        <span class="k">else</span><span class="p">:</span>
            <span class="c"># this is a derived class.  Add cls to the registry</span>
            <span class="n">interface_id</span> <span class="o">=</span> <span class="n">name</span><span class="o">.</span><span class="n">lower</span><span class="p">()</span>
            <span class="n">cls</span><span class="o">.</span><span class="n">registry</span><span class="p">[</span><span class="n">interface_id</span><span class="p">]</span> <span class="o">=</span> <span class="n">cls</span>
            
        <span class="nb">super</span><span class="p">(</span><span class="n">DBInterfaceMeta</span><span class="p">,</span> <span class="n">cls</span><span class="p">)</span><span class="o">.</span><span class="n">__init__</span><span class="p">(</span><span class="n">name</span><span class="p">,</span> <span class="n">bases</span><span class="p">,</span> <span class="n">dct</span><span class="p">)</span>
</pre></div>

</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Our metaclass simply adds a <code>registry</code> dictionary if it's not already
present, and adds the new class to the registry if the registry is already
there.  Let's see how this works:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [24]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">DBInterface</span><span class="p">(</span><span class="nb">object</span><span class="p">):</span>
    <span class="n">__metaclass__</span> <span class="o">=</span> <span class="n">DBInterfaceMeta</span>
    
<span class="k">print</span><span class="p">(</span><span class="n">DBInterface</span><span class="o">.</span><span class="n">registry</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">{}
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now let's create some subclasses, and double-check that they're added to
the registry:</p>
</div>
<div class="cell border-box-sizing code_cell vbox">
<div class="input hbox">
<div class="prompt input_prompt">In [25]:</div>
<div class="input_area box-flex1">
<div class="highlight-ipynb"><pre class="ipynb"><span class="k">class</span> <span class="nc">FirstInterface</span><span class="p">(</span><span class="n">DBInterface</span><span class="p">):</span>
    <span class="k">pass</span>

<span class="k">class</span> <span class="nc">SecondInterface</span><span class="p">(</span><span class="n">DBInterface</span><span class="p">):</span>
    <span class="k">pass</span>

<span class="k">class</span> <span class="nc">SecondInterfaceModified</span><span class="p">(</span><span class="n">SecondInterface</span><span class="p">):</span>
    <span class="k">pass</span>

<span class="k">print</span><span class="p">(</span><span class="n">DBInterface</span><span class="o">.</span><span class="n">registry</span><span class="p">)</span>
</pre></div>

</div>
</div>
<div class="vbox output_wrapper">
<div class="output vbox">
<div class="hbox output_area">
<div class="prompt output_prompt"></div>
<div class="output_subarea output_stream output_stdout">
<pre class="ipynb">{&apos;firstinterface&apos;: &lt;class &apos;__main__.FirstInterface&apos;&gt;,
 &apos;secondinterface&apos;: &lt;class &apos;__main__.SecondInterface&apos;&gt;,
 &apos;secondinterfacemodified&apos;: &lt;class &apos;__main__.SecondInterfaceModified&apos;&gt;}
</pre>
</div>
</div>
</div>
</div>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>It works as expected!  This could be used in conjunction with
a function that chooses implementations from the registry,
and any user-defined <code>Interface</code>-derived objects would be
automatically accounted for, without the user having to remember
to manually register the new types.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<h2 class="ipynb">
  Conclusion: When Should You Use Metaclasses?
</h2>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>I've gone through some examples of what metaclasses are, and some ideas 
about how they might be used to create very powerful and flexible APIs. 
Although metaclasses are in the background of everything you do in Python,
the average coder rarely has to think about them.</p>
<p>But the question remains: when should you think about using custom
metaclasses in your project?  It's a complicated question, but
there's a quotation floating around the web
that addresses it quite succinctly:</p>
<blockquote>
<p>Metaclasses are deeper magic than 99% of users should ever worry about.
If you wonder whether you need them, you don’t (the people who actually
need them know with certainty that they need them, and don’t need an
explanation about why).</p>
<p>– Tim Peters</p>
</blockquote>
<p>In a way, this is a very unsatisfying answer: it's a bit reminiscent of
the wistful and cliched explanation of the border between attraction
and love: "well, you just... know!"</p>
<p>But I think Tim is right: in general,
I've found that most tasks in Python that can be accomplished through
use of custom metaclasses can also be accomplished more cleanly and with
more clarity by other means.  As programmers, we should always be careful
to avoid being clever for the sake of cleverness alone, though
it is admittedly an ever-present temptation.</p>
<p>I personally spent six years doing science with Python, writing code
nearly on a daily basis, before I found a problem for which metaclasses
were the natural solution.  And it turns out Tim was right:</p>
<p>I just knew.</p>
</div>
<div class="text_cell_render border-box-sizing rendered_html">
<p>This post was written entirely in an IPython Notebook: the notebook file is available for
download <a href="http://jakevdp.github.com/downloads/notebooks/MetaClasses.ipynb">here</a>.
For more information on blogging with notebooks in octopress, see my
<a href="http://jakevdp.github.com/blog/2012/10/04/blogging-with-ipython/">previous post</a>
on the subject.</p>
</div>

</div>