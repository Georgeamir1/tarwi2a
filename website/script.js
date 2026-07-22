/* ============================================================
   Tarwi2a (ترويئة) — Landing Page Script
   ============================================================ */

(() => {
'use strict';

// ===== MENU DATA =====
const menuData = {
  soups: {
    name: 'الشوربة',
    emoji: 'assets/categories/soups.jpg',
    items: [
      { ar: 'شوربة كريمة بالجمبرى', en: 'Cream Soup with Shrimp', price: 170 },
      { ar: 'شوربة كريمة بالفراخ', en: 'Cream Soup with Chicken', price: 120 },
      { ar: 'شوربة كريمة مشروم وفراخ', en: 'Cream Soup with Mushroom and Chicken', price: 130 },
      { ar: 'شوربة كريمة بالمشروم', en: 'Cream Soup with Mushroom', price: 110 },
    ]
  },
  dishes: {
    name: 'أطباق متنوعة',
    emoji: 'assets/categories/dishes.jpg',
    items: [
      { ar: 'لازانيا لحم', en: 'Meat Lasagna', price: 195 },
      { ar: 'لازانيا فراخ', en: 'Chicken Lasagna', price: 185 },
      { ar: 'ريزو تشيكن بانيه', en: 'Rizo Chicken Pane', price: 85 },
      { ar: 'ريزو تشيكن زنجر', en: 'Rizo Chicken Zinger', price: 85 },
      { ar: 'ريزو تشيكن استربس', en: 'Rizo Chicken Strips', price: 85 },
      { ar: 'ريزو تشيكن فاهيتا', en: 'Rizo Chicken Fajita', price: 85 },
      { ar: 'ريزو شيش طاووق', en: 'Rizo Shish Taouk', price: 95 },
      { ar: 'باكت بطاطس', en: 'French Fries Packet', price: 45 },
      { ar: 'بطاطس وينجز', en: 'Potato Wings', price: 65 },
    ]
  },
  pans: {
    name: 'الطاسات',
    emoji: 'assets/categories/pans.jpg',
    items: [
      { ar: 'كبدة بالردة', en: 'Liver with Bran Pan', price: 75, note: 'ثمن كيلو' },
      { ar: 'كبدة عجالى بلدى باللية', en: 'Baladi Veal Liver with Tail Fat Pan', price: 100, note: 'ثمن كيلو' },
      { ar: 'كبدة اسكندرانى', en: 'Alexandrian Liver Pan', price: 75, note: 'ثمن كيلو' },
      { ar: 'سجق اسكندرانى', en: 'Alexandrian Sausage Pan', price: 75, note: 'ثمن كيلو' },
      { ar: 'مشكل بلدى', en: 'Mixed Baladi Pan', price: 100, desc: 'كبدة - فشة - سجق - حلويات', note: 'ثمن كيلو' },
      { ar: 'قلب على كلاوي', en: 'Heart and Kidneys Pan', price: 100, note: 'ثمن كيلو' },
      { ar: 'لحمة محمرة', en: 'Fried Meat Pan', price: 125, note: 'ثمن كيلو' },
      { ar: 'قلب عجالى', en: 'Veal Heart Pan', price: 100, note: 'ثمن كيلو' },
      { ar: 'كلاوي عجالى', en: 'Veal Kidneys Pan', price: 100, note: 'ثمن كيلو' },
      { ar: 'مخ عجالى', en: 'Veal Brain Pan', price: 125, note: 'ثمن كيلو' },
      { ar: 'سجق باليه الضانى', en: 'Lamb Sausage Pan with Tail Fat', price: 85, note: 'ثمن كيلو' },
      { ar: 'كبدة جملى', en: 'Camel Liver Pan', price: 125, note: 'ثمن كيلو' },
      { ar: 'مشكل جملى', en: 'Mixed Camel Pan', price: 110, note: 'ثمن كيلو' },
      { ar: 'قلب جملى', en: 'Camel Heart Pan', price: 110, note: 'ثمن كيلو' },
      { ar: 'مشكل جملى باليه', en: 'Mixed Camel with Tail Fat Pan', price: 110, note: 'ثمن كيلو' },
      { ar: 'ممبار عجالى', en: 'Veal Mumbar Pan', price: 125, note: 'نصف كيلو' },
      { ar: 'ممبار ضانى', en: 'Lamb Mumbar Pan', price: 85, note: 'نصف كيلو' },
      { ar: 'طحال', en: 'Spleen Pan', price: 180, note: 'نصف كيلو' },
    ]
  },
  crepes: {
    name: 'الكريب',
    emoji: 'assets/categories/crepes.jpg',
    items: [
      { ar: 'كريب بطاطس موتزريلا', en: 'Mozzarella Potato Crepe', price: 85 },
      { ar: 'كريب بطاطس ميكس جبن', en: 'Mixed Cheese Potato Crepe', price: 95 },
      { ar: 'كريب هوت دوج', en: 'Hot Dog Crepe', price: 120 },
      { ar: 'كريب بانيه', en: 'Pane Crepe', price: 120 },
      { ar: 'كريب استربس', en: 'Strips Crepe', price: 135 },
      { ar: 'كريب شيش طاووق', en: 'Shish Taouk Crepe', price: 135 },
      { ar: 'كريب ميكس فراخ', en: 'Mixed Chicken Crepe', price: 145 },
      { ar: 'كريب ميكس لحم', en: 'Mixed Meat Crepe', price: 150 },
      { ar: 'كريب كفتة بلدى', en: 'Baladi Kofta Crepe', price: 145 },
      { ar: 'كريب فاهيتا لحم', en: 'Meat Fajita Crepe', price: 145 },
      { ar: 'كريب فاهيتا فراخ', en: 'Chicken Fajita Crepe', price: 135 },
      { ar: 'كريب ترويئة', en: 'Tarwiza Crepe', price: 165 },
      { ar: 'كريب سجق شرقى', en: 'Eastern Sausage Crepe', price: 130 },
      { ar: 'كريب ميكس جبن', en: 'Mixed Cheese Crepe', price: 100 },
      { ar: 'كريب تشكن كرسبي', en: 'Chicken Crispy Crepe', price: 135 },
      { ar: 'كريب شاورما فراخ', en: 'Chicken Shawarma Crepe', price: 135 },
      { ar: 'كريب شاورما لحم', en: 'Meat Shawarma Crepe', price: 145 },
    ]
  },
  pizza: {
    name: 'البيتزا',
    emoji: 'assets/categories/pizza.jpg',
    items: [
      { ar: 'بيتزا مارجريتا', en: 'Marguerita Pizza', price: 155 },
      { ar: 'بيتزا هوت دوج', en: 'Hot Dog Pizza', price: 180 },
      { ar: 'بيتزا سوبر سوبريم', en: 'Super Supreme Pizza', price: 195 },
      { ar: 'بيتزا سوبر سوبريم فراخ', en: 'Chicken Super Supreme Pizza', price: 210 },
      { ar: 'بيتزا سجق شرقى', en: 'Eastern Sausage Pizza', price: 195 },
      { ar: 'بيتزا تشكن رانش', en: 'Chicken Ranch Pizza', price: 185 },
      { ar: 'بيتزا تشكن باربيكيو', en: 'Chicken BBQ Pizza', price: 190 },
      { ar: 'بيتزا ميكس فراخ', en: 'Mixed Chicken Pizza', price: 190 },
      { ar: 'بيتزا ميكس لحم', en: 'Mixed Meat Pizza', price: 220 },
      { ar: 'بيتزا خضروات', en: 'Vegetables Pizza', price: 175 },
      { ar: 'بيتزا ببرونى', en: 'Pepperoni Pizza', price: 185 },
      { ar: 'بيتزا جمبرى', en: 'Shrimp Pizza', price: 240 },
      { ar: 'بيتزا ميكس فود', en: 'Mixed Seafood Pizza', price: 230 },
      { ar: 'بيتزا تونة', en: 'Tuna Pizza', price: 195 },
      { ar: 'بيتزا بسطرمة', en: 'Pastrami Pizza', price: 180 },
      { ar: 'بيتزا كواترو فورماج', en: 'Quattro Formaggi Pizza', price: 155 },
      { ar: 'بيتزا ترويئة', en: 'Tarwiza Pizza', price: 140 },
      { ar: 'بيتزا فاهيتا فراخ', en: 'Chicken Fajita Pizza', price: 175 },
      { ar: 'بيتزا فاهيتا لحم', en: 'Meat Fajita Pizza', price: 180 },
      { ar: 'بيتزا كلازونى ميكس فراخ', en: 'Calzone Mixed Chicken', price: 250 },
      { ar: 'بيتزا كلازونى ميكس جبن', en: 'Calzone Mixed Cheese', price: 185 },
      { ar: 'بيتزا كلازونى ميكس سى فود', en: 'Calzone Mixed Seafood', price: 195 },
    ]
  },
  sandwiches: {
    name: 'الساندوتش',
    emoji: 'assets/categories/sandwiches.jpg',
    items: [
      { ar: 'كبدة اسكندرانى', en: 'Alexandrian Liver Sandwich', price: 40 },
      { ar: 'سجق اسكندرانى', en: 'Alexandrian Sausage Sandwich', price: 40 },
      { ar: 'كبدة بالردة', en: 'Liver with Bran Sandwich', price: 40 },
      { ar: 'كفتة عجالى', en: 'Veal Kofta Sandwich', price: 40 },
      { ar: 'حواوشى', en: 'Hawawshi Sandwich', price: 40 },
      { ar: 'قلب على كلاوي', en: 'Heart and Kidneys Sandwich', price: 50 },
      { ar: 'مشكل طاسة', en: 'Mixed Pan Sandwich', price: 70 },
      { ar: 'شيش طاووق', en: 'Shish Taouk Sandwich', price: 75 },
      { ar: 'طرب ضانى', en: 'Lamb Tarb Sandwich', price: 75 },
      { ar: 'مشكل لحمة راس', en: 'Mixed Head Meat Sandwich', price: 65 },
      { ar: 'مخ عجالى', en: 'Veal Brain Sandwich', price: 75 },
      { ar: 'كباب بلدى', en: 'Baladi Kabab Sandwich', price: 120 },
      { ar: 'قلب', en: 'Heart Sandwich', price: 50 },
      { ar: 'نيفه', en: 'Neefa Sandwich', price: 120 },
      { ar: 'سجق مشوى', en: 'Grilled Sausage Sandwich', price: 50 },
      { ar: 'كباب ضانى', en: 'Lamb Kabab Sandwich', price: 120 },
      { ar: 'كباب فلتو', en: 'Filet Kabab Sandwich', price: 120 },
      { ar: 'كبدة مشويه عجالى', en: 'Grilled Veal Liver Sandwich', price: 50 },
      { ar: 'مفروم اسكندرانى', en: 'Alexandrian Minced Meat Sandwich', price: 40 },
      { ar: 'سجق مدخن', en: 'Smoked Sausage Sandwich', price: 40 },
    ]
  },
  hawawshi: {
    name: 'حواوشي',
    emoji: 'assets/categories/hawawshi.jpg',
    items: [
      { ar: 'حواوشى ترويئة', en: 'Tarwiza Hawawshi', price: 75 },
      { ar: 'حواوشى رومى', en: 'Romi Hawawshi', price: 65, desc: 'لحمه + جبنه رومى + سجق' },
      { ar: 'حواوشى موتزريلا', en: 'Mozzarella Hawawshi', price: 65 },
      { ar: 'حواوشى فورمة', en: 'Forma Hawawshi', price: 125 },
      { ar: 'حواوشى لحمه مدخنة', en: 'Smoked Meat Hawawshi', price: 120 },
      { ar: 'حواوشى شيدر', en: 'Cheddar Hawawshi', price: 85 },
      { ar: 'حواوشى مكس جبن', en: 'Mixed Cheese Hawawshi', price: 80 },
      { ar: 'حواوشى سجق بالجبنه', en: 'Sausage with Cheese Hawawshi', price: 90 },
    ]
  },
  syrian: {
    name: 'سندوتشات سوري',
    emoji: 'assets/categories/syrian.jpg',
    items: [
      { ar: 'ساندوتش بطاطس', en: 'Potato Syrian Sandwich', price: 35 },
      { ar: 'ساندوتش بطاطس مكس جبن', en: 'Mixed Cheese Potato Syrian', price: 55 },
      { ar: 'ساندوتش بانيه', en: 'Pane Syrian Sandwich', price: 85 },
      { ar: 'ساندوتش شيش', en: 'Shish Syrian Sandwich', price: 90 },
      { ar: 'ساندوتش استربس', en: 'Strips Syrian Sandwich', price: 85 },
      { ar: 'ساندوتش زنجر', en: 'Zinger Syrian Sandwich', price: 85 },
      { ar: 'ساندوتش ميكس فراخ', en: 'Mixed Chicken Syrian Sandwich', price: 95 },
      { ar: 'ساندوتش كفته سوري', en: 'Syrian Kofta Sandwich', price: 110 },
      { ar: 'ساندوتش هوت دووج', en: 'Hot Dog Syrian Sandwich', price: 85 },
      { ar: 'ساندوتش كوردن بلو', en: 'Cordon Bleu Syrian Sandwich', price: 130 },
      { ar: 'ساندوتش فاهيتا فراخ', en: 'Chicken Fajita Syrian Sandwich', price: 90 },
      { ar: 'ساندوتش فاهيتا لحم', en: 'Meat Fajita Syrian Sandwich', price: 110 },
      { ar: 'ساندوتش ميكس لحوم', en: 'Mixed Meat Syrian Sandwich', price: 130 },
      { ar: 'ساندوتش ميكس فراخ (أخرى)', en: 'Mixed Chicken Syrian Extra', price: 120 },
    ]
  },
  pasta: {
    name: 'المعكرونات والمعجنات',
    emoji: 'assets/categories/pasta.jpg',
    items: [
      { ar: 'لازانيا لحم', en: 'Lasagna Meat', price: 195 },
      { ar: 'لازانيا فراخ', en: 'Lasagna Chicken', price: 185 },
    ]
  },
  rizo: {
    name: 'ريزو',
    emoji: 'assets/categories/rizo.jpg',
    items: [
      { ar: 'ريزو تشيكن بانيه', en: 'Chicken Pane Rizo', price: 85 },
      { ar: 'ريزو تشيكن زنجر', en: 'Chicken Zinger Rizo', price: 85 },
      { ar: 'ريزو تشيكن استربس', en: 'Chicken Strips Rizo', price: 85 },
      { ar: 'ريزو تشيكن فاهيتا', en: 'Chicken Fajita Rizo', price: 85 },
      { ar: 'ريزو شيش طاووق', en: 'Shish Taouk Rizo', price: 95 },
    ]
  },
  grills: {
    name: 'المشويات',
    emoji: 'assets/categories/grills.jpg',
    items: [
      { ar: 'فرخة مشوية سادة', en: 'Grilled Chicken Plain', price: 90, desc: 'سلطة، عيش، وطحينة', note: 'ربع فرخة' },
      { ar: 'فرخة مشوية', en: 'Grilled Chicken', price: 100, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ربع فرخة' },
      { ar: 'فرخة شيش', en: 'Shish Chicken', price: 105, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ربع فرخة' },
      { ar: 'موزة ضانى', en: 'Lamb Shank', price: 450, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل' },
      { ar: 'كفتة مشوية', en: 'Grilled Kofta', price: 90, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ثمن كيلو' },
      { ar: 'شيش طاووق', en: 'Grilled Shish Taouk', price: 95, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ثمن كيلو' },
      { ar: 'طرب ضانى', en: 'Lamb Tarb', price: 125, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ثمن كيلو' },
      { ar: 'كباب ضانى', en: 'Lamb Kabab', price: 130, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ثمن كيلو' },
      { ar: 'ريش ضاني', en: 'Lamb Ribs', price: 130, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ثمن كيلو' },
      { ar: 'نيفة ضانى', en: 'Lamb Neefa', price: 130, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ثمن كيلو' },
      { ar: 'سجق مشوي', en: 'Grilled Sausage', price: 90, desc: 'أرز بسمتي، سلطة، عيش، طحينة، ومخلل', note: 'ثمن كيلو' },
    ]
  },
  meals: {
    name: 'الوجبات',
    emoji: 'assets/categories/meals.jpg',
    items: [
      { ar: 'وجبة ربع فرخة "ورك"', en: 'Quarter Chicken Thigh Meal', price: 125, desc: 'ربع فرخة ورك + رز + عيش + سلطة + طحينة' },
      { ar: 'وجبة ربع فرخة "صدر"', en: 'Quarter Chicken Breast Meal', price: 135, desc: 'ربع فرخة صدر + رز + عيش + سلطة + طحينة' },
      { ar: 'وجبة نصف فرخة', en: 'Half Chicken Meal', price: 205, desc: 'نصف فرخة + رز + عيش + سلطة + طحينة' },
      { ar: 'وجبة ميكس', en: 'Mix Grill Meal', price: 175, desc: 'ربع فرخة ورك + 2 كفتة + رز بسمتي + عيش + سلطة + طحينة' },
      { ar: 'وجبة شواية', en: 'Shawayah Meal', price: 250, desc: 'ربع فرخة + 2 كفتة + 2 طرب + رز + عيش + سلطة + طحينة' },
      { ar: 'وجبة حمام محشي', en: 'Stuffed Pigeon Meal', price: 250, desc: 'فرد حمام محشي + أرز + سلطة + طحينة + عيش' },
      { ar: 'وجبة ضانى', en: 'Lamb Meal', price: 450, desc: 'ربع كباب ضانى + ربع كفتة ضانى + سلطة + طحينة + عيش' },
      { ar: 'وجبة مشكل مشاوي', en: 'Mixed Grills Platter', price: 300, desc: '2 كفتة + 2 شيش + 2 طرب + ربع فرخة + رز + سلطة + طحينة' },
      { ar: 'وجبة مشكل ترويئة', en: 'Mixed Tarwiza Platter', price: 175, desc: 'ثمن كفتة + ثمن شيش طاووق + رز + سلطة + طحينة' },
      { ar: 'وجبة سجق', en: 'Sausage Platter Meal', price: 170, desc: 'ربع سجق + رز + عيش + سلطة + طحينة' },
    ]
  },
  addons: {
    name: 'الإضافات',
    emoji: 'assets/categories/addons.jpg',
    items: [
      { ar: 'أرز بسمتي', en: 'Basmati Rice', price: 35 },
      { ar: 'مكرونة بشاميل', en: 'Pasta Bechamel', price: 110 },
      { ar: 'شوربة لسان عصفور', en: 'Orzo Soup', price: 45 },
      { ar: 'فتة خل وتوم', en: 'Fattah Vinegar & Garlic', price: 45 },
      { ar: 'سلطة', en: 'Green Salad', price: 20 },
      { ar: 'طحينة', en: 'Tehina Salad', price: 20 },
      { ar: 'مخلل', en: 'Pickles', price: 20 },
      { ar: 'إضافة جبنة', en: 'Extra Cheese', price: 40 },
      { ar: 'إضافة زيتون', en: 'Extra Olives', price: 20 },
      { ar: 'إضافة فراخ', en: 'Extra Chicken', price: 50 },
      { ar: 'إضافة لحوم', en: 'Extra Meat', price: 50 },
    ]
  },
  desserts: {
    name: 'الحلو',
    emoji: 'assets/categories/desserts.jpg',
    items: [
      { ar: 'كريب نوتيلا', en: 'Nutella Crepe', price: 120 },
    ]
  }
};

// ===== DOM ELEMENTS =====
const navbar = document.getElementById('navbar');
const navToggle = document.getElementById('navToggle');
const navLinks = document.getElementById('navLinks');
const menuGrid = document.getElementById('menuGrid');
const categoryFilter = document.getElementById('categoryFilter');
const heroParticles = document.getElementById('heroParticles');

// ===== NAVBAR SCROLL =====
let scrollTicking = false;
window.addEventListener('scroll', () => {
  if (!scrollTicking) {
    requestAnimationFrame(() => {
      const scrollY = window.scrollY;
      navbar.classList.toggle('scrolled', scrollY > 50);
      updateActiveNavLink();
      scrollTicking = false;
    });
    scrollTicking = true;
  }
});

function updateActiveNavLink() {
  const sections = ['hero', 'menu', 'payment', 'contact'];
  const navLinksAll = document.querySelectorAll('.nav-link');

  for (const sectionId of [...sections].reverse()) {
    const section = document.getElementById(sectionId);
    if (section && window.scrollY >= section.offsetTop - 200) {
      navLinksAll.forEach(link => link.classList.remove('active'));
      const activeLink = document.querySelector(`.nav-link[href="#${sectionId}"]`);
      if (activeLink) activeLink.classList.add('active');
      break;
    }
  }
}

// ===== MOBILE NAV TOGGLE =====
navToggle.addEventListener('click', () => {
  navToggle.classList.toggle('active');
  navLinks.classList.toggle('open');
  const isOpen = navLinks.classList.contains('open');
  navToggle.setAttribute('aria-expanded', isOpen);
  document.body.style.overflow = isOpen ? 'hidden' : '';
});

// Close mobile nav on link click
navLinks.querySelectorAll('.nav-link').forEach(link => {
  link.addEventListener('click', () => {
    navToggle.classList.remove('active');
    navLinks.classList.remove('open');
    navToggle.setAttribute('aria-expanded', 'false');
    document.body.style.overflow = '';
  });
});

// ===== HERO PARTICLES =====
function createParticles() {
  const count = window.innerWidth < 768 ? 12 : 25;
  for (let i = 0; i < count; i++) {
    const particle = document.createElement('div');
    particle.className = 'particle';
    particle.style.left = `${Math.random() * 100}%`;
    particle.style.animationDelay = `${Math.random() * 8}s`;
    particle.style.animationDuration = `${6 + Math.random() * 6}s`;
    particle.style.width = `${2 + Math.random() * 4}px`;
    particle.style.height = particle.style.width;
    particle.style.opacity = 0.1 + Math.random() * 0.5;
    heroParticles.appendChild(particle);
  }
}
createParticles();

// ===== RENDER MENU =====
let activeCategory = 'all';
let searchQuery = '';

function getFilteredMenu(catKey, query) {
  const cat = menuData[catKey];
  if (!cat) return [];
  if (!query) return cat.items;
  const q = query.trim().toLowerCase();
  return cat.items.filter(item => {
    return item.ar.toLowerCase().includes(q) || 
           item.en.toLowerCase().includes(q) || 
           (item.desc && item.desc.toLowerCase().includes(q));
  });
}

function renderMenu(filter = 'all', searchVal = '') {
  activeCategory = filter;
  searchQuery = searchVal;
  menuGrid.innerHTML = '';

  const categories = filter === 'all' ? Object.keys(menuData) : [filter];
  let totalItemsFound = 0;

  categories.forEach(catKey => {
    const cat = menuData[catKey];
    if (!cat) return;

    const filteredItems = getFilteredMenu(catKey, searchQuery);
    if (filteredItems.length === 0) return;

    totalItemsFound += filteredItems.length;

    // Category header
    const groupHeader = document.createElement('div');
    groupHeader.className = 'menu-category-group';
    groupHeader.innerHTML = `
      <div class="category-header">
        <div class="category-emoji">
          <img src="${cat.emoji}" alt="${cat.name}">
        </div>
        <div>
          <div class="category-name">${cat.name}</div>
          <div class="category-count">${filteredItems.length} صنف</div>
        </div>
      </div>
    `;
    menuGrid.appendChild(groupHeader);

    // Items
    filteredItems.forEach((item, index) => {
      const card = document.createElement('div');
      card.className = 'menu-card';
      // Stagger animation delay up to 12 items to prevent long animations
      card.style.animationDelay = `${Math.min(index * 30, 360)}ms`;

      let descHtml = '';
      if (item.desc) {
        descHtml = `<p class="menu-card-desc">${item.desc}</p>`;
      }

      let noteHtml = '';
      if (item.note) {
        noteHtml = `<span class="menu-card-note">${item.note}</span>`;
      }

      card.innerHTML = `
        <div class="menu-card-top">
          <div>
            <div class="menu-card-name">
              ${item.ar}
              <span class="menu-card-name-en">${item.en}</span>
            </div>
            ${noteHtml}
          </div>
          <div class="menu-card-price">
            ${item.price}
            <span class="currency">ج.م</span>
          </div>
        </div>
        ${descHtml}
      `;

      menuGrid.appendChild(card);
    });
  });

  // Handle Search Results Badge & Empty State
  const badge = document.getElementById('searchResultsBadge');
  const countSpan = document.getElementById('resultsCount');
  const clearBtn = document.getElementById('clearSearchBtn');
  const emptyState = document.getElementById('menuEmptyState');

  if (searchQuery) {
    badge.classList.remove('hidden');
    countSpan.textContent = totalItemsFound;
    clearBtn.classList.remove('hidden');
  } else {
    badge.classList.add('hidden');
    clearBtn.classList.add('hidden');
  }

  if (totalItemsFound === 0) {
    emptyState.classList.remove('hidden');
    menuGrid.style.display = 'none';
  } else {
    emptyState.classList.add('hidden');
    menuGrid.style.display = 'grid';
  }
}

// ===== SEARCH EVENT LISTENERS =====
const searchInput = document.getElementById('menuSearchInput');
const clearSearchBtn = document.getElementById('clearSearchBtn');
const resetSearchBtn = document.getElementById('resetSearchBtn');

if (searchInput) {
  let debounceTimer;
  searchInput.addEventListener('input', (e) => {
    const value = e.target.value;
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      renderMenu(activeCategory, value);
    }, 200);
  });
}

if (clearSearchBtn) {
  clearSearchBtn.addEventListener('click', () => {
    searchInput.value = '';
    renderMenu(activeCategory, '');
    searchInput.focus();
  });
}

if (resetSearchBtn) {
  resetSearchBtn.addEventListener('click', () => {
    searchInput.value = '';
    
    // Reset category filter visual state
    categoryFilter.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('active'));
    const allBtn = categoryFilter.querySelector('[data-category="all"]');
    if (allBtn) {
      allBtn.classList.add('active');
    allBtn.setAttribute('aria-pressed', 'true');
      allBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
    }
    
    renderMenu('all', '');
  });
}

// ===== CATEGORY FILTER =====
categoryFilter.addEventListener('click', e => {
  const btn = e.target.closest('.cat-btn');
  if (!btn) return;

  categoryFilter.querySelectorAll('.cat-btn').forEach(b => {
    b.classList.remove('active');
    b.setAttribute('aria-pressed', 'false');
  });
  btn.classList.add('active');
  btn.setAttribute('aria-pressed', 'true');

  // Center active category chip smoothly
  btn.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });

  // Clear search on category change for clean filtering experience
  if (searchInput) searchInput.value = '';

  const category = btn.dataset.category;
  renderMenu(category, '');

  // Smooth scroll to menu top
  document.getElementById('menu').scrollIntoView({ behavior: 'smooth', block: 'start' });
});

// ===== CATEGORY SCROLL FADES =====
const filterWrapper = document.getElementById('categoryFilterWrapper');
const filterScroll = document.getElementById('categoryFilter');

function updateScrollFades() {
  if (!filterScroll || !filterWrapper) return;
  
  const scrollWidth = filterScroll.scrollWidth;
  const clientWidth = filterScroll.clientWidth;
  const scrollLeft = Math.abs(filterScroll.scrollLeft);
  
  if (scrollWidth <= clientWidth) {
    filterWrapper.classList.remove('fade-left', 'fade-right');
    return;
  }
  
  const isAtStart = scrollLeft < 5;
  const isAtEnd = scrollLeft >= (scrollWidth - clientWidth - 5);
  
  // RTL view logic: start is right, end is left
  if (isAtStart) {
    filterWrapper.classList.add('fade-left');
    filterWrapper.classList.remove('fade-right');
  } else if (isAtEnd) {
    filterWrapper.classList.add('fade-right');
    filterWrapper.classList.remove('fade-left');
  } else {
    filterWrapper.classList.add('fade-left', 'fade-right');
  }
}

if (filterScroll) {
  filterScroll.addEventListener('scroll', updateScrollFades);
  window.addEventListener('resize', updateScrollFades);
  // Run after elements layout
  setTimeout(updateScrollFades, 200);
}

// ===== SCROLL REVEAL =====
function observeReveal(el) {
  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

  observer.observe(el);
}

// Observe static sections with stagger delay
document.querySelectorAll('.feature-card, .payment-card, .contact-card, .section-header').forEach((el) => {
  el.classList.add('reveal');
  const siblings = el.parentElement.querySelectorAll('.reveal');
  const siblingIndex = Array.from(siblings).indexOf(el);
  el.style.setProperty('--stagger-delay', `${Math.min(siblingIndex * 80, 400)}ms`);
  observeReveal(el);
});

// ===== COPY TO CLIPBOARD (Pill Box) =====
document.querySelectorAll('.payment-number').forEach(pill => {
  pill.addEventListener('click', async () => {
    const btn = pill.querySelector('.copy-btn');
    if (!btn) return;
    const number = btn.dataset.copy;
    try {
      await navigator.clipboard.writeText(number);
      pill.classList.add('copied');
      showToast();
      setTimeout(() => pill.classList.remove('copied'), 2000);
    } catch {
      // Fallback
      const input = document.createElement('input');
      input.value = number;
      document.body.appendChild(input);
      input.select();
      document.execCommand('copy');
      document.body.removeChild(input);
      pill.classList.add('copied');
      showToast();
      setTimeout(() => pill.classList.remove('copied'), 2000);
    }
  });
});

function showToast() {
  const toast = document.getElementById('toast');
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 2500);
}

// ===== SMOOTH SCROLL FOR NAV LINKS =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});

// ===== GLOBAL IMAGE ERROR FALLBACK (UI/UX Pro Max) =====
function handleImgFallback(img) {
  img.onerror = null; // Prevent infinite loops
  // A clean red outline circle plate SVG representation
  img.src = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="%23E02B2B" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"/></svg>`;
  img.style.padding = '4px';
  img.style.background = 'var(--primary-light)';
}

function checkAndFallbackImages() {
  document.querySelectorAll('img').forEach(img => {
    // If the image fails to load in the future
    img.addEventListener('error', function() {
      handleImgFallback(this);
    });
    // Check if the image has already failed to load before script ran
    if (img.complete && img.naturalWidth === 0) {
      handleImgFallback(img);
    }
  });
}

// Watch dynamically added items via MutationObserver
const menuGridObserver = new MutationObserver((mutations) => {
  mutations.forEach(mutation => {
    mutation.addedNodes.forEach(node => {
      if (node.nodeType === Node.ELEMENT_NODE) {
        if (node.tagName === 'IMG') {
          node.addEventListener('error', function() { handleImgFallback(this); });
        }
        node.querySelectorAll('img').forEach(img => {
          img.addEventListener('error', function() { handleImgFallback(this); });
          if (img.complete && img.naturalWidth === 0) {
            handleImgFallback(img);
          }
        });
      }
    });
  });
});
menuGridObserver.observe(menuGrid, { childList: true, subtree: true });

// Run checks
checkAndFallbackImages();

// ===== WHATSAPP FAB BOUNCE-IN ON SCROLL =====
const whatsappFab = document.querySelector('.whatsapp-fab');
if (whatsappFab) {
  const heroSection = document.getElementById('hero');
  const fabObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) {
        whatsappFab.classList.add('fab-visible');
      } else {
        whatsappFab.classList.remove('fab-visible');
      }
    });
  }, { threshold: 0.1 });

  if (heroSection) {
    fabObserver.observe(heroSection);
  } else {
    // Fallback: show after scrolling 300px
    window.addEventListener('scroll', () => {
      if (window.scrollY > 300) {
        whatsappFab.classList.add('fab-visible');
      } else {
        whatsappFab.classList.remove('fab-visible');
      }
    }, { passive: true });
  }
}

// ===== INIT =====
renderMenu('all');

})();
