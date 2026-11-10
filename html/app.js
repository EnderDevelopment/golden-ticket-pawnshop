const app = document.getElementById('app');
const itemsEl = document.getElementById('items');
const categoriesEl = document.getElementById('categories');
const searchEl = document.getElementById('search');
const toastEl = document.getElementById('toast');
let items = [], category = 'All';

const post = (event, data = {}) => fetch(`https://${GetParentResourceName()}/${event}`, {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(data)});
const money = value => '$' + Number(value).toLocaleString('en-US');

function renderCategories() {
    const categories = ['All', ...new Set(items.map(item => item.category))];
    categoriesEl.innerHTML = categories.map(name => `<button class="category ${name === category ? 'active' : ''}" data-category="${name}">${name}</button>`).join('');
    categoriesEl.querySelectorAll('.category').forEach(button => button.onclick = () => { category = button.dataset.category; renderCategories(); renderItems(); });
}
function renderItems() {
    const query = searchEl.value.toLowerCase();
    const visible = items.filter(item => (category === 'All' || item.category === category) && `${item.label} ${item.description}`.toLowerCase().includes(query));
    itemsEl.innerHTML = visible.length ? visible.map(item => `<article class="item"><div class="item-top"><div class="item-icon">${item.icon || '◆'}</div><strong class="item-price">${money(item.price)}</strong></div><h3>${item.label}</h3><p>${item.description || 'A valuable item accepted by the shop.'}</p><div class="item-foot"><span class="stock">Sell any quantity</span><button class="sell" data-name="${item.name}">Sell item</button></div></article>`).join('') : '<p style="color:var(--muted);grid-column:1/-1;text-align:center;padding:40px">No matching items found.</p>';
    itemsEl.querySelectorAll('.sell').forEach(button => button.onclick = () => sell(button.dataset.name));
}
function sell(name) {
    const amount = prompt('How many would you like to sell?', '1');
    if (amount === null) return;
    const quantity = Number(amount);
    if (!Number.isInteger(quantity) || quantity < 1) return showToast('Enter a whole number greater than zero.', true);
    post('sell', {name, amount: quantity});
}
function showToast(message, error = false) {
    toastEl.textContent = message; toastEl.className = `toast show${error ? ' error' : ''}`;
    setTimeout(() => toastEl.className = 'toast', 3500);
}
window.addEventListener('message', event => {
    const data = event.data;
    if (data.action === 'open') { items = data.items || []; document.getElementById('shop-name').textContent = data.shopName || 'Pawnshop'; category = 'All'; app.classList.remove('hidden'); renderCategories(); renderItems(); }
    if (data.action === 'close') app.classList.add('hidden');
    if (data.action === 'saleResult') showToast(data.message, !data.success);
});
searchEl.addEventListener('input', renderItems);
document.getElementById('close').onclick = () => post('close');
document.addEventListener('keydown', event => { if (event.key === 'Escape') post('close'); });
