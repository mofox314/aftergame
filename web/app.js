(() => {
  const games = Array.isArray(window.AFTERGAME_GAMES) ? window.AFTERGAME_GAMES : [];
  const collator = new Intl.Collator('en', { sensitivity: 'base', numeric: true });
  games.sort((a, b) => collator.compare(a.title, b.title));

  if (document.body.dataset.page === 'detail') {
    const root = document.getElementById('detail');
    const id = new URLSearchParams(location.search).get('id');
    const game = games.find((item) => item.id === id);
    if (!game) {
      root.className = 'empty'; root.textContent = 'Game not found.'; return;
    }
    document.title = game.title + ' · aftergame';
    const cover = document.createElement('img');
    cover.className = 'detail-cover'; cover.src = game.image; cover.alt = game.title + ' cover';
    const content = document.createElement('div'); content.className = 'detail-content';
    const heading = document.createElement('div'); heading.className = 'detail-heading';
    const title = document.createElement('h1'); title.className = 'detail-title'; title.textContent = game.title;
    const score = document.createElement('p'); score.className = 'detail-score'; score.textContent = game.score + '/10';
    heading.append(title, score);
    const description = document.createElement('p'); description.className = 'detail-description'; description.textContent = game.description;
    content.append(heading, description);
    root.append(cover, content);
    return;
  }

  const search = document.getElementById('search');
  const root = document.getElementById('games');
  function render() {
    root.replaceChildren();
    const query = search.value.trim().toLocaleLowerCase('en');
    const visible = games.filter((game) => game.title.toLocaleLowerCase('en').includes(query));
    if (!visible.length) {
      const empty = document.createElement('div'); empty.className = 'empty';
      empty.textContent = games.length ? 'No matching games.' : 'No games listed.';
      root.append(empty); return;
    }
    for (const game of visible) {
      const card = document.createElement('a');
      card.className = 'game-card'; card.href = 'game.html?id=' + encodeURIComponent(game.id);
      card.setAttribute('aria-label', game.title);
      const cover = document.createElement('img');
      cover.className = 'game-thumb'; cover.src = game.image; cover.alt = ''; cover.loading = 'lazy';
      card.append(cover); root.append(card);
    }
  }
  search.addEventListener('input', render);
  render();
})();
