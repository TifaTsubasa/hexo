<div class="nav-collapse  menu-item">
  <ul>
    <li><a href="/">Home</a></li>
    <li><a href="/categories">Category</a></li>
    <li><a href="/archives">Up</a></li>
    <li><a href="/tags">About</a></li>
  </ul>
  <div class="sidebar-toggle">
    <img id="menu-logo" src="{{ theme.avatar or url_for(theme.images) + '/default_avatar.jpg' }}" />
    <!--<div class="sidebar-toggle-line-wrap">-->
    <!--<span class="sidebar-toggle-line sidebar-toggle-line-first"></span>-->
    <!--<span class="sidebar-toggle-line sidebar-toggle-line-middle"></span>-->
    <!--<span class="sidebar-toggle-line sidebar-toggle-line-last"></span>-->
    <!--</div>-->
  </div>
</div>

<script>
  var navigation = responsiveNav(".nav-collapse", {
    animate: true,                    // Boolean: Use CSS3 transitions, true or false
    transition: 400,                  // Integer: Speed of the transition, in milliseconds
    label: "Menu",                    // String: Label for the navigation toggle
//          insert: "after",                  // String: Insert the toggle before or after the navigation
    customToggle: "",                 // Selector: Specify the ID of a custom toggle
//    closeOnNavClick: false,           // Boolean: Close the navigation when one of the links are clicked
//    openPos: "relative",              // String: Position of the opened nav, relative or static
    navClass: "nav-collapse",         // String: Default CSS class. If changed, you need to edit the CSS too!
    navActiveClass: "js-nav-active",  // String: Class that is added to <html> element when nav is active
    jsClass: "js",                    // String: 'JS enabled' class which is added to <html> element
    init: function(){},               // Function: Init callback
    open: function(){},               // Function: Open callback
    close: function(){}               // Function: Close callback
  });
</script>
<!--
<div class="site-meta {% if theme.custom_logo.enabled %}custom-logo{% endif %}">
  {% if theme.custom_logo.image and not theme.scheme %}
    <div class="site-meta-headline">
      <a>
        <img class="custom-logo-image" src="{{ theme.custom_logo.image }}"
             alt="{{ config.title }}"/>
      </a>
    </div>
  {% endif %}

  <div class="custom-logo-site-title">
    <a href="{{ config.root }}"  class="brand" rel="start">
      <span class="logo-line-before"><i></i></span>
      <span class="site-title">{{ config.title }}</span>
      <span class="logo-line-after"><i></i></span>
    </a>
  </div>
  <p class="site-subtitle">{{ config.subtitle }}</p>
</div>

<div class="site-nav-toggle">
  <button>
    <span class="btn-bar"></span>
    <span class="btn-bar"></span>
    <span class="btn-bar"></span>
  </button>
</div>

<nav class="site-nav">
  {% set hasSearch = theme.swiftype_key || theme.tinysou_Key %}

  {% if theme.menu %}
    <ul id="menu" class="menu {{ hasSearch and 'menu-left' }}">
      {% for name, path in theme.menu %}
        {% set itemName = name.toLowerCase() %}
        <li class="menu-item menu-item-{{ itemName }}">
          <div width="100%" height="100px"></div>
          <a href="{{ url_for(path) }}" rel="section">
            {% if theme.menu_icons.enable %}
              <i class="menu-item-icon fa fa-{{theme.menu_icons[itemName] || 'question-circle'}}"></i> <br />
            {% endif %}
            {{ __('menu.' + itemName) }}
          </a>
        </li>
      {% endfor %}

      {# Search icon for default scheme #}
      {% if not theme.scheme and theme.swiftype_key %}
        <li class="menu-item menu-item-search">
          <a href="#" class="st-search-show-outputs">
            {% if theme.menu_icons.enable %}
              <i class="menu-item-icon fa fa-search icon-next-search"></i> <br />
            {% endif %}
            {{ __('menu.search') }}
          </a>
        </li>
      {% endif %}
    </ul>
  {% endif %}

  {% if hasSearch %}
    <div class="site-search">
      {% include 'search.swig' %}
    </div>
  {% endif %}
</nav>
-->
