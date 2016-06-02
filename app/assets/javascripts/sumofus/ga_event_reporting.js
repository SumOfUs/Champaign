(function(){
  const EVENTS_TO_REPORT = [
    "direct_debit:opened",
    "direct_debit:donated_via_other",
    "direct_debit:donated",
  ];

  $.subscribe(EVENTS_TO_REPORT.join(' '), function(ev){
    let splitted = ev.type.split(':');
    let eventCategory = (splitted.length > 1) ? splitted[0] : 'generic';
    let eventAction =   (splitted.length > 1) ? splitted[1] : splitted[0];
    if(typeof window.ga === 'function') {
      window.ga('send', 'event', eventCategory, eventAction);
    }
  });
})();
