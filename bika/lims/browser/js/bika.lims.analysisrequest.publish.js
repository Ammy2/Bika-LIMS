/**
 * Controller class for Analysis Service Edit view
 */
function AnalysisRequestPublishView() {

    var that = this;

    var report_format    = $('#ar_publish_container #sel_format');
    var report_container = $('#ar_publish_container #report');

    var referrer_cookie_name = '_arpv';

    /**
     * Entry-point method for AnalysisRequestPublishView
     */
    that.load = function() {

        // Store referrer in cookie in case it is lost due to a page reload
        var backurl = document.referrer;
        if (backurl) {
            var d = new Date();
            d.setTime(d.getTime() + (1*24*60*60*1000));
            document.cookie = referrer_cookie_name + '=' + document.referrer + '; expires=' + d.toGMTString() + '; path=/';
        } else {
            var cookies = document.cookie.split(';');
            for(var i=0; i<cookies.length; i++) {
                var cookie = cookies[i];
                while (cookie.charAt(0)==' ') {
                    cookie = cookie.substring(1);
                }
                if (cookie.indexOf(referrer_cookie_name) != -1) {
                    backurl = cookie.substring(referrer_cookie_name.length+1, cookie.length);
                    break;
                }
            }
            // Fallback to portal_url instead of staying inside publish.
            if (!backurl) {
                backurl = portal_url;
            }
        }

        // Smooth scroll to content
        $('#ar_publish_container #ar_publish_summary a[href^="#"]').click(function(e) {
            e.preventDefault();
            var anchor = $(this).attr('href');
            var offset = $(anchor).first().offset().top - 20;
            $('html,body').animate({scrollTop: offset},'slow');
        });

        $('#sel_format').change(function(e) {
            reloadReport();
        });

        $('#qcvisible').click(function(e) {
            reloadReport();
        });

        $('#hvisible').click(function(e) {
            reloadReport();
        });

        $('#publish_button').click(function(e) {
            var url = window.location.href;
            var qcvisible = $('#qcvisible').is(':checked') ? 1 : 0;
            var hvisible = $('#hvisible').is(':checked') ? 1 : 0;
            var template = $('#sel_format').val();
            $('#ar_publish_container').animate({opacity:0.4}, 'slow');
            var count = $('#ar_publish_container #report .ar_publish_body').length;
            $('#ar_publish_container #report .ar_publish_body').each(function(){
                var rephtml = $(this).clone().wrap('<div>').parent().html();
                var repstyle = $('#report-style').clone().wrap('<div>').parent().html();
                $.ajax({
                    url: url,
                    type: 'POST',
                    async: true,
                    data: { "publish":1,
                            "id":$(this).attr('id'),
                            "uid":$(this).attr('uid'),
                            "html": rephtml,
                            "template": template,
                            "qcvisible": qcvisible,
                            "hvisible": hvisible,
                            "style": repstyle}
                })
                .always(function(){
                    if (!--count) {
                        location.href=backurl;
                    }
                });
            });
        });

        $('#cancel_button').click(function(e) {
            location.href=backurl;
        });

        load_barcodes();
        load_pagination();

        var invalidbackurl = window.portal_url + '/++resource++bika.lims.images/report_invalid_back.png';
        $('.ar-invalid').css('background', "url('"+invalidbackurl+"') repeat scroll #ffffff");

        var provisbackurl = window.portal_url + '/++resource++bika.lims.images/report_provisional_back.png';
        $('.ar-provisional').css('background', "url('"+provisbackurl+"') repeat scroll #ffffff");

        $('#sel_format_info').click(function(e) {
            e.preventDefault();
            $('#sel_format_info_pane').toggle();
        });

    }

    function get(name){
       if(name=(new RegExp('[?&]'+encodeURIComponent(name)+'=([^&]*)')).exec(location.search))
          return decodeURIComponent(name[1]);
    }

    function load_barcodes() {
        // Barcode generator
        $('.barcode').each(function() {
            var id = $(this).attr('data-id');
            var code = $(this).attr('data-code');
            var barHeight = $(this).attr('data-barHeight');
            var addQuietZone = $(this).attr('data-addQuietZone');
            var showHRI = $(this).attr('data-showHRI');
            $(this).barcode(id, code,
                            {'barHeight': parseInt(barHeight),
                             'addQuietZone': Boolean(addQuietZone),
                             'showHRI': Boolean(showHRI) });
        });
    }

    function load_pagination() {
        $(".paginated-report").each(function(i) {
            var numpages = $(this).find('.page-footer').length;
            $(this).find('.page-total-count').html(numpages);
            $(this).find('.page-current-num').each(function(i) {
                $(this).html(i+1);
            });
        });
    }

    function reloadReport() {
        var url = window.location.href;
        var template = $('#sel_format').val();
        var qcvisible = $('#qcvisible').is(':checked') ? '1' : '0';
        var hvisible = $('#hvisible').is(':checked') ? '1' : '0';
        $('#report').fadeTo('fast', 0.4);
        //$('#report').animate({opacity:0.4}, 'slow');
        $.ajax({
            url: url,
            type: 'POST',
            async: true,
            data: { "template": template,
                    "qcvisible": qcvisible,
                    "hvisible": hvisible}
        })
        .always(function(data) {
            var htmldata = data;
            cssdata = $(htmldata).find('#report-style').html();
            $('#report-style').html(cssdata);
            htmldata = $(htmldata).find('#report').html();
            $('#report').html(htmldata);
            $('#report').fadeTo('fast', 1);
            load_barcodes();
            load_pagination();
        });
    }
}
