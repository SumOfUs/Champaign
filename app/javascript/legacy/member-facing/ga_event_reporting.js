if (window.event) {
  const EVENTS_TO_REPORT = [
    'direct_debit:opened',
    'direct_debit:donated_via_other',
    'direct_debit:donated',
  ];

  EVENTS_TO_REPORT.forEach(e => {
    const [category, action] = e.split(':');
    window.ee.on(e, () => {
      if (typeof window.ga === 'function') {
        window.ga('send', 'event', category, action);
      }
    });
  });
}
