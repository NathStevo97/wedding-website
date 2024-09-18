// Navigation

function toggleMenu() {
    const toggleMenu = document.querySelector(".toggleMenu");
    const navigation = document.querySelector(".navigation");
    toggleMenu.classList.toggle("active");
    navigation.classList.toggle("active");
}
// End Navigation

// Swiper
var swiper = new Swiper(".mySwiper", {
    effect: "cards",
    grabCursor: true,
    loop: true,
    autoplay: {
        delay: 2500,
        disableOnInteraction: false,
    },
});
// End Swiper

function filterPage(mainClass) {
    const allTab = document.querySelectorAll(`${mainClass} .filter-btn`);

    allTab.forEach((tab) => {
        tab.addEventListener("click", function () {
            console.log("clicked");
            allTab.forEach((tab) => {
                tab.classList.remove("active");
            });
            this.classList.add("active");
            const tabContent = document.querySelectorAll(`${mainClass} .filter-cards`);
            tabContent.forEach((content) => {
                content.classList.remove("t-active");
            });
            const tabActive = document.querySelector(
                `${mainClass} .tab` + this.dataset.tab
            );
            tabActive.classList.add("t-active");
        });
    });
}
filterPage(".bridal");
filterPage(".itinerary");