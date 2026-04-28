(function() {
  "use strict";

  // Resaltar enlace de navegacion activo segun la pagina actual
  function setActiveNav() {
    var path = window.location.pathname;
    var links = document.querySelectorAll(".nav-link");
    links.forEach(function(link) {
      link.classList.remove("active");
      var href = link.getAttribute("href");
      if (path.endsWith(href) || (path === "/" && href === "index.html")) {
        link.classList.add("active");
      }
    });
  }

  // Animacion sencilla de aparicion para tarjetas de productos
  function animateCards() {
    var cards = document.querySelectorAll(".product-card, .feature-card");
    if (!cards.length) return;
    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          entry.target.style.opacity = "1";
          entry.target.style.transform = "translateY(0)";
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 });
    cards.forEach(function(card) {
      card.style.opacity = "0";
      card.style.transform = "translateY(20px)";
      card.style.transition = "opacity 0.4s ease, transform 0.4s ease";
      observer.observe(card);
    });
  }

  document.addEventListener("DOMContentLoaded", function() {
    setActiveNav();
    animateCards();
  });
})();
