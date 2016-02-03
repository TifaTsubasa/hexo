<!doctype html>
<html class="theme-next {% if theme.use_motion %}use-motion{% endif %} {% if theme.scheme %}theme-next-{{ theme.scheme | lower }}{% endif %}">
<head>
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
</head>

<body itemscope itemtype="http://schema.org/WebPage" lang="{{ config.language }}">

  {% include '_partials/old-browsers.swig' %}
  {% include '_scripts/analytics.swig' %}
  <div class="container one-column {% block page_class %}{% endblock %}">

    <div class="headband"></div>

    <!--<header id="header" class="header" itemscope itemtype="http://schema.org/WPHeader">-->
      <div hidden="hidden" class="header-inner"> {%- include '_partials/header.swig' %} </div>
    <!-- </header> -->


    <main id="main" class="main">
      <div class="nav-collapse">
        <ul>
          <li><a href="#">Home</a></li>
          <li><a href="#">About</a></li>
          <li><a href="#">Projects</a></li>
          <li><a href="#">Contact</a></li>
        </ul>
      </div>
      <script>
        var navigation = responsiveNav(".nav-collapse", {
          animate: true,                    // Boolean: Use CSS3 transitions, true or false
          transition: 400,                  // Integer: Speed of the transition, in milliseconds
          label: "Menu",                    // String: Label for the navigation toggle
//          insert: "after",                  // String: Insert the toggle before or after the navigation
          customToggle: "",                 // Selector: Specify the ID of a custom toggle
          closeOnNavClick: false,           // Boolean: Close the navigation when one of the links are clicked
          openPos: "relative",              // String: Position of the opened nav, relative or static
          navClass: "nav-collapse",         // String: Default CSS class. If changed, you need to edit the CSS too!
          navActiveClass: "js-nav-active",  // String: Class that is added to <html> element when nav is active
          jsClass: "js",                    // String: 'JS enabled' class which is added to <html> element
          init: function(){},               // Function: Init callback
          open: function(){},               // Function: Open callback
          close: function(){}               // Function: Close callback
        });
      </script>
      <div class="main-inner">
        <div id="content" class="content"> {% block content %}{% endblock %} </div>

        {% if (theme.duoshuo_hotartical and page.title) %}
            <!-- 多说热评文章-->
            <p>热评文章</p>
            <div class="ds-top-threads" data-range="weekly" data-num-items="4"></div>
        {% endif %}

        {% if page.comments %}
          <div class="comments" id="comments">
            {% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}
              <div class="ds-thread" data-thread-key="{{ page.path }}"
                   data-title="{{ page.title }}" data-url="{{ page.permalink }}">
              </div>
            {% elseif theme.disqus_shortname %}
              <div id="disqus_thread">
                <noscript>Please enable JavaScript to view the <a href="//disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
              </div>
            {% endif %}
          </div>
        {% endif %}
      </div>

      {% if theme.sidebar !== 'remove' %}
        {% block sidebar %}{% endblock %}
      {% endif %}
    </main>

    <footer id="footer" class="footer">
      <div class="footer-inner"> {% include '_partials/footer.swig' %} </div>
    </footer>

    <div class="back-to-top"></div>
  </div>

  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/jquery/index.js?v=2.1.3"></script>

  {# This block is used to set options before any other scripts run #}
  {% block script_extra_before %}{% endblock %}
  {% block comment_system %}
    {% include '_scripts/comments/duoshuo.swig' %}
    {% include '_scripts/comments/disqus.swig' %}
  {% endblock %}
  {% include '_scripts/fancy-box.swig' %}
  {% include '_scripts/helpers.swig' %}
  {% include '_scripts/motion.swig' %}

  <script type="text/javascript" src="{{ url_for(theme.js) }}/nav-toggle.js?v={{ theme.version }}"></script>
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/fastclick/lib/fastclick.min.js?v=1.0.6"></script>

  {% block script_extra %}{% endblock %}

  <script type="text/javascript">
    $(document).ready(function () {
      if (CONFIG.sidebar === 'always') {
        displaySidebar();
      }
      if (isMobile()) {
        FastClick.attach(document.body);
      }

      motionIntegrator.bootstrap();
    });
  </script>

  {% include '_scripts/tinysou.swig' %}
  {% include '_scripts/mathjax.swig' %}
  {% block comment_system %}{% endblock %}
  {% include '_scripts/baidushare.swig' %}

  {# LazyLoad #}
  <script type="text/javascript" src="{{ url_for(theme.js) }}/lazyload.js"></script>
  <script type="text/javascript">
    $(function () {
      $("#posts").find('img').lazyload({
        placeholder: "{{ url_for(theme.images) }}/loading.gif",
        effect: "fadeIn"
      });
    });
  </script>
</body>
</html>
