<!doctype html>
<html class="theme-next {% if theme.use_motion %}use-motion{% endif %} {% if theme.scheme %}theme-next-{{ theme.scheme | lower }}{% endif %}">
<head>
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
</head>

<body itemscope itemtype="https://schema.org/WebPage" lang="{{ config.language }}">
  {% include '_partials/old-browsers.swig' %}
  {% include '_scripts/analytics.swig' %}
  <div class="container one-column {% block page_class %}{% endblock %}">

    <div class="headband"></div>

    <header id="header" class="header" itemscope itemtype="https://schema.org/WPHeader">
      <div class="header-inner"> {%- include '_partials/header.swig' %} </div>
     </header>
    <div class="sidebar-toggle">
      <img id="menu-logo" src="{{ theme.avatar or url_for(theme.images) + '/default_avatar.jpg' }}" />
      <!--<div class="sidebar-toggle-line-wrap">-->
      <!--<span class="sidebar-toggle-line sidebar-toggle-line-first"></span>-->
      <!--<span class="sidebar-toggle-line sidebar-toggle-line-middle"></span>-->
      <!--<span class="sidebar-toggle-line sidebar-toggle-line-last"></span>-->
      <!--</div>-->
    </div>

    <main id="main" class="main">
      <div class="main-inner">
        <div id="content" class="content"> {% block content %}{% endblock %} </div>

        {% if (theme.duoshuo_hotartical and page.title) %}
            <!-- 多说热评文章-->
            <p>热评文章</p>
            <div class="ds-top-threads" data-range="weekly" data-num-items="4"></div>
        {% endif %}

        <script>
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
              (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

          ga('create', 'UA-73798439-1', 'auto');
          ga('send', 'pageview');

        </script>

        {% if page.comments %}
          <div class="comments" id="comments">
            <div class="ds-share" data-thread-key="{{ page.path }}" data-title="{{ page.title }}" data-images="{{ page.permalink}}" data-content="{{ page.permalink }}" data-url="{{ page.permalink }}">
              <div class="ds-share-inline">
                <ul  class="ds-share-icons-16">

                  <li data-toggle="ds-share-icons-more"><a class="ds-more" href="javascript:void(0);">分享到：</a></li>
                  <li><a class="ds-weibo" href="javascript:void(0);" data-service="weibo">微博</a></li>
                  <li><a class="ds-qzone" href="javascript:void(0);" data-service="qzone">QQ空间</a></li>
                  <li><a class="ds-qqt" href="javascript:void(0);" data-service="qqt">腾讯微博</a></li>
                  <li><a class="ds-wechat" href="javascript:void(0);" data-service="wechat">微信</a></li>

                </ul>
                <div class="ds-share-icons-more">
                </div>
              </div>
            </div>

            <!--{% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}-->
              <!--<div class="ds-thread" data-thread-key="{{ page.path }}"-->
                   <!--data-title="{{ page.title }}" data-url="{{ page.permalink }}">-->
              <!--</div>-->
            <!--{% elseif theme.disqus_shortname %}-->
              <!--<div id="disqus_thread">-->
                <!--<noscript>Please enable JavaScript to view the <a href="//disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>-->
              <!--</div>-->
            <!--{% endif %}-->
            <!-- 多说评论框 start -->
            <div class="ds-thread" data-thread-key="{{ page.path }}" data-title="{{ page.title }}" data-url="{{ page.permalink }}"></div>
            <!-- 多说评论框 end -->
            <!-- 多说公共JS代码 start (一个网页只需插入一次) -->
            <script type="text/javascript">
              var duoshuoQuery = {short_name:"tifatsubasa"};
              (function() {
                var ds = document.createElement('script');
                ds.type = 'text/javascript';ds.async = true;
                ds.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + '//static.duoshuo.com/embed.js';
                ds.charset = 'UTF-8';
                (document.getElementsByTagName('head')[0]
                || document.getElementsByTagName('body')[0]).appendChild(ds);
              })();
            </script>
            <!-- 多说公共JS代码 end -->
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
//      if (isMobile()) {
//        FastClick.attach(document.body);
//      }

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
