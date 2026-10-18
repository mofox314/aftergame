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
    const top = document.createElement('div'); top.className = 'detail-top';
    const cover = document.createElement('img'); cover.className = 'detail-cover'; cover.src = game.image; cover.alt = game.title + ' cover';
    const text = document.createElement('div');
    const title = document.createElement('h1'); title.className = 'detail-title'; title.textContent = game.title;
    const score = document.createElement('p'); score.className = 'detail-score'; score.textContent = 'Score: ' + game.score + '/10';
    text.append(title, score); top.append(cover, text);
    const description = document.createElement('p'); description.className = 'detail-description'; description.textContent = game.description;
    root.append(top, description);
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
      const row = document.createElement('a'); row.className = 'game-row'; row.href = 'game.html?id=' + encodeURIComponent(game.id);
      const cover = document.createElement('img'); cover.className = 'game-thumb'; cover.src = game.image; cover.alt = '';
      const title = document.createElement('span'); title.className = 'game-title'; title.textContent = game.title;
      const score = document.createElement('span'); score.className = 'game-score'; score.textContent = game.score + '/10';
      row.append(cover, title, score); root.append(row);
    }
  }
  search.addEventListener('input', render);
  render();
})();
