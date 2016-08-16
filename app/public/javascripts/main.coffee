'use strict'
root = exports ? this
$ ->
# $(window).load ->
  # console.debug 'coffee ready'

  debug = true

  root.productionHost = "YOUR_DOMAIN.com.tw" # "/([a-z.]*).senao.com.tw/g"; # /([a-z.]*).senao.com.tw|10.0.200.4/g
  unacceptable = (str, reg) ->
    re = new RegExp(reg, "g")
    (str.match(re) != null)
  root.env = "development"
  root.env = if unacceptable(location.href, productionHost) then "production" else "development"

  # if location.hostname

  root.APIs = {
    "development": {
      "citytown": "/public/apis/API_taiwan_area.json",

    },
    "production": {
      "citytown": "//m.senao.com.tw/dev_ec/jfiles/API_taiwan_area.json",
    }
  }

  root.twCityTownData
  root.twCityTownDataOfStore
  root.storeData

  ###
  prototype
  ###

  ### 字串中抓取數字 ###
  unless "getNumber" of String::
    String::getNumber = ->
      m = undefined
      r = ''
      re = /\d+/ig
      while (m = re.exec(@toString())) != null
        r += @substring(m.index, re.lastIndex)
      parseInt(r, 10) || 0
  unless "getNumber" of Number::
    Number::getNumber = ->
      return @
  # 千分位
  unless "numberWithCommas" of String::
    String::numberWithCommas = ->
      @replace(/\d{1,3}(?=(\d{3})+$)/g, (s) -> "#{s},")

  ###
    --- functions ---
  ###
  GetSortOrder = (prop) ->
    return (a, b)->
        if (a[prop] > b[prop])
            return 1
        else if (a[prop] < b[prop])
            return -1
        return 0

  # fancybox popup
  # root.popupup_lightbox = (_url = '', _type = 'iframe' )->
  #   fancybox_info =
  #     maxWidth: 800
  #     maxHeight: 800
  #     padding: 10
  #     fitToView: false
  #     autoResize: true
  #     closeClick: false
  #     autoSize: true
  #     type: _type
  #     href: _url
  #     helpers:
  #       overlay:
  #         closeClick: false
  #   # if 'inline' is _type
  #   #   fancybox_info.closeBtn = false
  #   fancybox_info = $.extend(fancybox_info, _url) if "object" is typeof _url
  #   $.fancybox.open fancybox_info if $.fancybox.open

  ###
  # iframe onload resize
  # <iframe src="" onload="resizeIframe(this)" ></iframe>
  ###
  root.resizeIframe = (obj) ->
    if obj
      obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px'
  root.SetCwinHeight = (iframeId)->
    _iframe = document.getElementById(iframeId)
    if(_iframe)
      $(_iframe).height( $("##{iframeId}")[0].contentWindow.top.document.body.scrollHeight )
    return



  class tool

    thistool = this

    constructor: ->
      console.debug 'tool ready'

    ###
      === Header ===
    ###


  class googleMapClass

    _then = @
    @loction
    @storeLocation
    root.map
    @marker
    ### development key ###
    key = 'GOOGLE_MAP_API_KEY'

    constructor: ->

      # loadScript
      $.when(
        $.getScript( "//cdnjs.cloudflare.com/ajax/libs/gmaps.js/0.4.24/gmaps.min.js" )
        $.getScript( "//maps.googleapis.com/maps/api/js?v=3.21&key=#{key}" )
        $.Deferred( ( deferred )-> $( deferred.resolve ) )
      ).done (jd)->
        _then.initialize()

    @initialize: ->
      # console.log {lat:$('#gmapdata').data('lat'), lng: $('#gmapdata').data('lng')}
      ### callback function ###
      root.map = new GMaps(
        el: "#map_canvas",
        lat: $('#gmapdata').data('lat'),
        lng: $('#gmapdata').data('lng')
      )
      root.map.setCenter($('#gmapdata').data('lat'), $('#gmapdata').data('lng'))

    ### 設定座標 ###
    setLocation: (lat, lng, elementId = 'map_canvas', data)->

      ### set infowindow content ###
      contentString = "<div class=\"map-info\">"+
        "<div class=\"btn-group\">"+
        "<a class=\"btn btn-query btn-sm\" target=\"_blank\" href=\"http://maps.google.com.tw/maps?f=q&hl=zh-TW&geocode=&z=14&output=embed&q=台彎省#{data['county']}#{data['district']}#{data['address']}+停車\">如何前往</a></div></div>"

      # this.map.setCenter({
      #   lat: lat
      #   lng: lng
      # })

      root.map.addMarker({
        lat: lat
        lng: lng
        zoom: 13
        center: @loction
        controls:
          panControl: true
          mapTypeControl: false
          scaleControl: false
          streetViewControl: false
          rotateControl: false
        title: "#{data['storeName']} - #{data['typeShortName']}中心",
        infoWindow: {
          content: contentString
        },
        click: (e) ->
          ga('send','event','google-map-marker','click', "#{data['storeName']} - #{data['typeShortName']}中心")
          # console.log(['ga', 'send','event','google-map-marker','click', "#{data['storeName']} - #{data['typeShortName']}中心"])
      })
      google.maps.event.trigger(document.getElementById('map_canvas'), "resize")
      root.map.setCenter($('#gmapdata').data('lat'), $('#gmapdata').data('lng'))
      return

    deleteOverlays: ->
      root.map.removeMarkers()
      return

    ### events ###
    $('#mapModal').on 'shown.bs.modal', (event)->
      # console.log 'in deleteOverlays shown modal'
      googleMap.setLocation( $('#gmapdata').data('lat'), $('#gmapdata').data('lng'), 'map_canvas', storeData )

      # $.when(
      #   googleMap.deleteOverlays()
      #   googleMap.initialize()
      # ).done ->
      #   googleMap.setLocation( $('#gmapdata').data('lat'), $('#gmapdata').data('lng'), 'map_canvas', storeData )



  class articleClass

    # 分頁tab切換使用 add_tab_of_product
    _then = @

    @page = 1
    @show = 20
    @count = 0
    @totalPages = 0
    @countNews = 0
    @newsData

    @tags =
      'mobile': '新機'
      'topic': '專題'
      'news': '新聞'
      'app': '應用程式'
      'knowledge': '神知識'
      'latest': '最新消息'


    constructor: ->
      $('.js-article-body .card-group').each (i, v) ->
        $(v).parents().eq(0).find('.js-article-btn')[ if $(v).find('section').length > 0 then 'removeClass' else 'addClass' ]('hide')
      # 作用域 js-article-body

    getPage: (_type='', _page)->
      # console.warn "[article] not ready with this function, category = #{_type}"
      $.getJSON
      _url = "#{APIs[env]['article']}?show=#{_then.show}&page=#{_page}&category=#{_type}"
      # _url = "/public/apis/API_post_list_null.json?show=#{_then.show}&page=#{_page}" if _page > 8
      _ajax = $.getJSON(_url)
      _ajax.done (jd) ->

        if _page >= jd['success']['totalPages']
          $('.js-article-btn').addClass('hide')
          return false


        _then.newsData = jd['success']['list']
        _then.setNewsView(_type, _page)
        # console.log '[article] down'
      return

    @setNewsView: (_type='', _page=1)->
      # console.log 'setNewsView'
      $.each @newsData, (i, v) ->
        v['content'] = v['summary'] or v['title']#decodeURIComponent(v['content'].replace(/\n/g, "").replace(/<\/?[^>]+(>|$)/g, "").replace(/&nbsp;/g,"").replace(/圖、文／/g,"").substr(0, 50))

        _time = moment.unix(v['_published'].toString().substr(0,10)).format("YYYY/MM/DD HH:ss")

        # console.log v['categories']
        _tags = ""
        $.each v['categories'], (index, value) ->
          # console.log v['categories'], value, _then.tags[value]
          _tags += "<a href=\"/Article/List/#{value}\" class=\"tag-text-primary\"><i class=\"icon icon-tag\"></i>#{_then.tags[value]}</a>"

        _section = """
          <section class=\"card quarter \" data-tag=\"#{v['summary']}\">
          <div class=\"card-img\"><a href=\"/Article/Detail/#{v['_seqId']}\"><img alt=\"文章圖\" src=\"#{v['iconImg']}\"></a></div>
          <div class=\"card-content\">
          <h4 class=\"title\"><a href=\"/Article/Detail/#{v['_seqId']}\">#{v['title']}</a></h4>
          <p class=\"desc\">#{v['content']}</p>
          <div class=\"info\">
          <time datetime=\"#{_time}\" class=\"date has-inline\"><i class=\"icon icon-clock\"></i>#{_time}</time>
          #{_tags}
          </div>
          </div>
          </section>
          """
        $(".js-article-body[data-category='#{_type}'] .card-group").append _section
      $(".js-article-body[data-category='#{_type}'] .js-article-btn").data('page', (_page + 1) )


      return

  ###
   --- views ---
  ###
  root.app = new tool


  ###
    Header
  ###

  ### 串header購物車 (部分功能暫時停用 - 剩下品項total顯示) ###
  app.get_header_cart() if $('header .hc-right #cart-items-total').length > 0

  ### header menu 開關 ###
  if $('.js-header-menu').length > 0
    $('.js-header-menu .popover-nav a').on 'click', ->
      $('.js-header-menu')[ if $('.js-header-menu').hasClass('active') then 'removeClass' else 'addClass' ]('active')
      $('body:not(.js-header-menu)').one 'click', -> $('.js-header-menu').removeClass('active') if $('.js-header-menu').hasClass('active')
      false

  ### header ad banner open/close ###
  $('header .btn.btn-inverted-outline.btn-mini').on 'click', ->
    $(@).text( if $('header .ad.popup').hasClass('is-open') then $(@).data('close') else $(@).data('open') )
    $('header .ad.popup')[ if $('header .ad.popup').hasClass('is-open') then 'removeClass' else 'addClass' ]('is-open')

  ###
    Slider
  ###
