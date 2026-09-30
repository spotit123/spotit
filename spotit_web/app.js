/* JS logic for SpotIt Madrid Simulator & Landing Page */
document.addEventListener('DOMContentLoaded', () => {
  // Default mock bars data
  const defaultBars = [
    {
      id: '1',
      name: 'La Chiave',
      type: 'Indie / Cocktail Bar',
      description: 'Storico ritrovo madrileno con un suggestivo giardino interno. Atmosfera informale, ottima selezione musicale indie/rock e cocktail ricercati.',
      rating: 4.7,
      reviewCount: 940,
      address: 'Calle de Fuencarral 46, Madrid',
      latitude: 40.4282,
      longitude: -3.7020,
      imageUrl: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=600&q=80',
      distance: 0.6,
      popularDrinks: ['Etna Mule', 'Negroni del Capo', 'Gin Tonic Siciliano'],
      isFavorite: false,
      vibeTags: ['Energetic', 'Underground', 'Chill'],
      crowdDensity: 85,
      crowdAge: '20s-30s',
      genderRatio: '55% F / 45% M',
      hasMusic: true,
      musicType: 'Indie Rock',
      galleryImages: [
        'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1536935338788-846bb9981813?auto=format&fit=crop&w=600&q=80',
      ],
      reviews: [
        {
          userName: 'Marco Rossini',
          userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
          rating: 5,
          comment: 'Giardino interno stupendo e drink eccezionali. Il mio posto preferito in Via Gemmellaro!',
          date: '02/06'
        },
        {
          userName: 'Giulia Bianchi',
          userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
          rating: 4,
          comment: 'Ottima musica indie, molto affollato nel weekend ma l\'atmosfera è fantastica.',
          date: '31/05'
        }
      ]
    },
    {
      id: '2',
      name: 'Vermut',
      type: 'Tapas & Vermutteria',
      description: 'Locale specializzato in vermut artigianali e taglieri tipici. Clima conviviale e tavoli all\'aperto nella vivacissima Malasaña.',
      rating: 4.6,
      reviewCount: 1120,
      address: 'Calle de San Vicente Ferrer 37, Madrid',
      latitude: 40.4270,
      longitude: -3.7025,
      imageUrl: 'https://images.unsplash.com/photo-1574096079513-d8259312b785?auto=format&fit=crop&w=600&q=80',
      distance: 0.7,
      popularDrinks: ['Vermut Rojo', 'Negroni Blanco', 'Madrid Mule'],
      isFavorite: false,
      vibeTags: ['Chill', 'Energetic'],
      crowdDensity: 92,
      crowdAge: '30s-40s',
      genderRatio: '50% M / 50% F',
      hasMusic: true,
      musicType: 'Ambient Jazz',
      galleryImages: [
        'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=600&q=80',
      ],
      reviews: [
        {
          userName: 'Salvatore K.',
          userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&q=80',
          rating: 5,
          comment: 'I migliori salumi della zona e vermut artigianale da capogiro. Super consigliato.',
          date: '04/06'
        }
      ]
    },
    {
      id: '3',
      name: 'Boheme Mixology Bar',
      type: 'Mixology Speakeasy',
      description: 'Cocktail bar d\'alta gamma nascosto tra le vie del centro. Divani in velluto, luci soffuse e drink sartoriali creati su misura per te.',
      rating: 4.9,
      reviewCount: 310,
      address: 'Calle del Barco 12, Madrid',
      latitude: 40.4223,
      longitude: -3.7011,
      imageUrl: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=600&q=80',
      distance: 0.9,
      popularDrinks: ['Smoked Boulevardier', 'Sartorial Sour', 'Old Fashioned Barrique'],
      isFavorite: false,
      vibeTags: ['Chill', 'Jazz', 'Underground'],
      crowdDensity: 45,
      crowdAge: 'Professionals',
      genderRatio: '45% F / 55% M',
      hasMusic: true,
      musicType: 'Classic Jazz',
      galleryImages: [
        'https://images.unsplash.com/photo-151097252790b-af4f90267300?auto=format&fit=crop&w=600&q=80',
      ],
      reviews: [
        {
          userName: 'Filippo M.',
          userAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=100&q=80',
          rating: 5,
          comment: 'Esperienza unica. Ti fanno il drink su misura basandosi sui tuoi gusti. Eccellente.',
          date: '01/06'
        }
      ]
    },
    {
      id: '4',
      name: 'Razmataz',
      type: 'Wine Bar & Bistro',
      description: 'Enoteca storica situata in una caratteristica via pedonale. Atmosfera parigina, ottima selezione di vini dell\'Etna e taglieri gourmet.',
      rating: 4.5,
      reviewCount: 780,
      address: 'Calle de Valverde 34, Madrid',
      latitude: 40.4235,
      longitude: -3.7032,
      imageUrl: 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?auto=format&fit=crop&w=600&q=80',
      distance: 0.5,
      popularDrinks: ['Etna Rosso DOC', 'Nerello Mascalese'],
      isFavorite: false,
      vibeTags: ['Chill', 'Jazz', 'Rooftop'],
      crowdDensity: 60,
      crowdAge: '30s-50s',
      genderRatio: '60% F / 40% M',
      hasMusic: false,
      musicType: 'None',
      galleryImages: [],
      reviews: [
        {
          userName: 'Elena R.',
          userAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80',
          rating: 4,
          comment: 'Selezione vini dell\'Etna insuperabile. La via Penninello è bellissima per sedersi all\'aperto.',
          date: '28/05'
        }
      ]
    },
    {
      id: '5',
      name: 'Agora Bar',
      type: 'Open Air Bar & Social',
      description: 'Locale vivacissimo. Tavoli all\'aperto nella piazza con frequente musica dal vivo.',
      rating: 4.4,
      reviewCount: 1420,
      address: 'Plaza de San Ildefonso 2, Madrid',
      latitude: 40.4245,
      longitude: -3.7021,
      imageUrl: 'https://images.unsplash.com/photo-1536935338788-846bb9981813?auto=format&fit=crop&w=600&q=80',
      distance: 0.2,
      popularDrinks: ['Spritz Siculo', 'Zibibbo Cold'],
      isFavorite: false,
      vibeTags: ['Energetic', 'Neon', 'Live Music'],
      crowdDensity: 88,
      crowdAge: 'Gen Z / Students',
      genderRatio: '50% F / 50% M',
      hasMusic: true,
      musicType: 'Pop / Reggaeton',
      galleryImages: [
        'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=600&q=80',
      ],
      reviews: [
        {
          userName: 'Davide P.',
          userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
          rating: 5,
          comment: 'Caotico, energico, bellissimo. Proprio accanto alla Pescheria, vibe fantastica!',
          date: '03/06'
        }
      ]
    }
  ];

  // Initialize data from LocalStorage or use default
  let bars = JSON.parse(localStorage.getItem('spotit_madrid_bars')) || defaultBars;
  let userProfile = JSON.parse(localStorage.getItem('spotit_madrid_profile')) || {
    name: 'Alex Rivers',
    username: '@vibe_seeker_99',
    location: 'Madrid',
    age: 25,
    bookingsCount: 24,
    favoritesCount: 12,
    karma: 4.8
  };

  // Add persistent simulator collections
  let bookings = JSON.parse(localStorage.getItem('spotit_madrid_bookings')) || [
    { id: 'b1', barName: 'La Chiave', userName: 'Marco Rossini', time: '21:30', guestCount: 2, joinPriorityList: true, date: 'Oggi' },
    { id: 'b2', barName: 'Vermut', userName: 'Giulia Bianchi', time: '20:30', guestCount: 4, joinPriorityList: false, date: 'Ieri' }
  ];

  let registeredUsers = JSON.parse(localStorage.getItem('spotit_madrid_users')) || [
    { name: 'Alex Rivers', username: '@vibe_seeker_99', role: 'Amministratore' },
    { name: 'Marco Rossini', username: '@marco_r', role: 'Utente Pro' },
    { name: 'Giulia Bianchi', username: '@giulia_b', role: 'Vibe Explorer' },
    { name: 'Salvatore K.', username: '@salvo_k', role: 'Local Guide' }
  ];

  let activeVibe = 'Tutti';
  let selectedBar = null;
  let currentRating = 5;

  // DOM Elements
  const phoneContent = document.getElementById('phone-content');
  const vibeChipsContainer = document.getElementById('vibe-chips-container');
  const detailSheet = document.getElementById('detail-sheet');
  const bookingView = document.getElementById('booking-view');
  const profileView = document.getElementById('profile-view');
  const successDialog = document.getElementById('success-dialog');
  const reviewModal = document.getElementById('review-modal');

  // Load profile button avatar
  const profileBtnImg = document.getElementById('profile-btn-img');
  if (profileBtnImg) {
    profileBtnImg.src = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80';
  }

  // Save changes to localStorage and update views
  function saveData() {
    localStorage.setItem('spotit_madrid_bars', JSON.stringify(bars));
    localStorage.setItem('spotit_madrid_profile', JSON.stringify(userProfile));
    localStorage.setItem('spotit_madrid_bookings', JSON.stringify(bookings));
    localStorage.setItem('spotit_madrid_users', JSON.stringify(registeredUsers));
    
    // Update Landing page spots stats dynamically too!
    renderLandingGrid();
    
    // Sincronizza ed esegui il rendering della Dashboard Admin
    if (typeof renderAdminPanel === 'function') {
      renderAdminPanel();
    }
  }

  // Render Vibe filter chips inside simulator
  const vibes = ['Tutti', 'Chill', 'Energetic', 'Jazz', 'Live Music', 'Underground', 'Neon'];
  vibeChipsContainer.innerHTML = '';
  vibes.forEach(vibe => {
    const chip = document.createElement('div');
    chip.className = `vibe-chip ${vibe === activeVibe ? 'active' : ''}`;
    chip.innerText = vibe;
    chip.addEventListener('click', () => {
      document.querySelectorAll('.vibe-chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      activeVibe = vibe;
      renderSpots();
    });
    vibeChipsContainer.appendChild(chip);
  });

  // Render Bar Cards inside simulator
  function renderSpots() {
    phoneContent.innerHTML = '';
    const filtered = activeVibe === 'Tutti' 
      ? bars 
      : bars.filter(bar => bar.vibeTags.includes(activeVibe));

    if (filtered.length === 0) {
      phoneContent.innerHTML = `
        <div style="text-align:center; padding: 40px 10px; color: var(--text-grey); font-size: 13px;">
          Nessun locale per la vibe "${activeVibe}"
        </div>
      `;
      return;
    }

    filtered.forEach(bar => {
      const card = document.createElement('div');
      card.className = 'sim-bar-card';
      
      const tagsHtml = bar.vibeTags.map(tag => `<div class="sim-card-tag">${tag}</div>`).join('');
      const capClass = bar.crowdDensity > 80 ? 'high' : 'low';

      card.innerHTML = `
        <div class="sim-card-image" style="background-image: url('${bar.imageUrl}');">
          <div class="sim-card-distance">${bar.distance} km</div>
          <div class="sim-card-fav ${bar.isFavorite ? 'active' : ''}" data-id="${bar.id}">
            <span class="material-icons-round" style="font-size: 16px;">favorite</span>
          </div>
        </div>
        <div class="sim-card-info">
          <div class="sim-card-title-row">
            <div class="sim-card-title">${bar.name}</div>
            <div class="sim-card-rating">
              <span class="material-icons-round" style="font-size: 14px;">star</span>
              <span>${bar.rating}</span>
            </div>
          </div>
          <div class="sim-card-type">${bar.type}</div>
          <div class="sim-card-vibe-tags">${tagsHtml}</div>
          <div class="sim-card-insights-row">
            <div class="sim-card-music">
              <span class="material-icons-round icon">music_note</span>
              <span>${bar.hasMusic ? bar.musicType : 'Nessuna'}</span>
            </div>
            <div class="sim-card-capacity ${capClass}">${bar.crowdDensity}% Cap.</div>
          </div>
        </div>
      `;

      // Favorite toggle
      const favBtn = card.querySelector('.sim-card-fav');
      favBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        bar.isFavorite = !bar.isFavorite;
        favBtn.classList.toggle('active', bar.isFavorite);
        userProfile.favoritesCount = bars.filter(b => b.isFavorite).length;
        saveData();
      });

      // Open detail sheet
      card.addEventListener('click', () => {
        openDetailSheet(bar);
      });

      phoneContent.appendChild(card);
    });
  }

  // Open Detail Screen Sheet inside phone
  function openDetailSheet(bar) {
    selectedBar = bar;
    
    document.getElementById('detail-header-img').style.backgroundImage = `url('${bar.imageUrl}')`;
    document.getElementById('detail-title').innerText = bar.name;
    document.getElementById('detail-rating-label').innerText = `${bar.rating} (${bar.reviewCount} recensioni) • ${bar.type}`;
    
    // Set favorite icon active status
    const detailFavBtn = document.getElementById('detail-fav-btn');
    detailFavBtn.classList.toggle('active', bar.isFavorite);

    // Vibe tags
    const tagsRow = document.getElementById('detail-tags-row');
    tagsRow.innerHTML = bar.vibeTags.map(tag => `<div class="phone-detail-tag">${tag}</div>`).join('');

    // Insights
    document.getElementById('detail-crowd-age').innerText = bar.crowdAge;
    document.getElementById('detail-gender-ratio').innerText = bar.genderRatio;
    document.getElementById('detail-density-txt').innerText = `${bar.crowdDensity}% di capacità`;
    document.getElementById('detail-density-bar').style.width = `${bar.crowdDensity}%`;
    document.getElementById('detail-density-bar').style.backgroundColor = bar.crowdDensity > 80 ? '#ff3366' : '#0066ff';
    document.getElementById('detail-description').innerText = bar.description;

    // Gallery
    renderDetailGallery(bar);

    // Reviews list
    renderReviews(bar);

    detailSheet.classList.add('active');
  }

  // Render gallery in detail view
  function renderDetailGallery(bar) {
    const galleryRow = document.getElementById('detail-gallery-row');
    galleryRow.innerHTML = '';
    
    // Add Main Image
    const mainImg = document.createElement('img');
    mainImg.className = 'gallery-img';
    mainImg.src = bar.imageUrl;
    galleryRow.appendChild(mainImg);

    // Add extra images
    bar.galleryImages.forEach(img => {
      const gImg = document.createElement('img');
      gImg.className = 'gallery-img';
      gImg.src = img;
      galleryRow.appendChild(gImg);
    });

    // Add upload button
    const addBtn = document.createElement('div');
    addBtn.className = 'gallery-add-btn';
    addBtn.innerHTML = '<span class="material-icons-round">add_a_photo</span>';
    addBtn.addEventListener('click', () => {
      // Curated nightlife stock photos
      const images = [
        'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-151097252790b-af4f90267300?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=600&q=80'
      ];
      
      const newImg = images[Math.floor(Math.random() * images.length)];
      bar.galleryImages.push(newImg);
      saveData();
      renderDetailGallery(bar);
      
      alert("Foto caricata con successo nella galleria del locale!");
    });
    galleryRow.appendChild(addBtn);
  }

  // Render Reviews inside detail view
  function renderReviews(bar) {
    const reviewsList = document.getElementById('reviews-list');
    reviewsList.innerHTML = '';

    if (!bar.reviews || bar.reviews.length === 0) {
      reviewsList.innerHTML = `
        <div style="font-size:11px; color:var(--text-dark-grey); text-align:center; padding: 12px 0;">
          Nessuna recensione ancora. Sii il primo!
        </div>
      `;
      return;
    }

    bar.reviews.forEach(rev => {
      const item = document.createElement('div');
      item.className = 'phone-review-item';
      
      let starsHtml = '';
      for (let i = 1; i <= 5; i++) {
        starsHtml += `<span class="material-icons-round" style="font-size:10px; color:${i <= rev.rating ? '#ffb800' : 'var(--text-dark-grey)'}">star</span>`;
      }

      item.innerHTML = `
        <div class="review-item-header">
          <img class="review-avatar" src="${rev.userAvatar}" alt="avatar">
          <div class="review-user-info">
            <div class="review-username">${rev.userName}</div>
            <div class="review-date">${rev.date}</div>
          </div>
          <div class="review-rating">${starsHtml}</div>
        </div>
        <div class="review-comment">${rev.comment}</div>
      `;
      reviewsList.appendChild(item);
    });
  }

  // Add review stars selector event listeners
  const reviewStars = document.querySelectorAll('.review-star-btn');
  reviewStars.forEach(star => {
    star.addEventListener('click', () => {
      const val = parseInt(star.getAttribute('data-value'));
      currentRating = val;
      
      reviewStars.forEach(s => {
        const sVal = parseInt(s.getAttribute('data-value'));
        s.classList.toggle('active', sVal <= val);
      });
    });
  });

  // Submit Review inside simulator
  document.getElementById('submit-review-btn').addEventListener('click', () => {
    const commentInput = document.getElementById('review-input-text');
    const comment = commentInput.value.trim();
    if (!comment) return;

    const newRev = {
      userName: userProfile.name,
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
      rating: currentRating,
      comment: comment,
      date: 'Oggi'
    };

    if (!selectedBar.reviews) selectedBar.reviews = [];
    selectedBar.reviews.unshift(newRev);

    // Recompute bar ratings
    selectedBar.reviewCount = selectedBar.reviews.length;
    const total = selectedBar.reviews.reduce((sum, r) => sum + r.rating, 0);
    selectedBar.rating = parseFloat((total / selectedBar.reviewCount).toFixed(1));

    commentInput.value = '';
    reviewModal.classList.remove('active');
    
    saveData();
    renderSpots();
    openDetailSheet(selectedBar);
  });

  // Open Maps Navigation
  document.getElementById('detail-directions-btn').addEventListener('click', () => {
    if (!selectedBar) return;
    const url = `https://www.google.com/maps/search/?api=1&query=${selectedBar.latitude},${selectedBar.longitude}`;
    window.open(url, '_blank');
  });

  // Open booking screen inside phone
  document.getElementById('detail-secure-btn').addEventListener('click', () => {
    if (!selectedBar) return;
    
    document.getElementById('booking-bar-img').src = selectedBar.imageUrl;
    document.getElementById('booking-bar-name').innerText = selectedBar.name;
    document.getElementById('booking-bar-desc').innerText = `${selectedBar.rating} • ${selectedBar.type}`;
    document.getElementById('booking-live-capacity').innerText = `Live: ${selectedBar.crowdDensity}% Cap.`;
    
    bookingView.classList.add('active');
  });

  // Booking confirming simulation
  document.getElementById('confirm-booking-btn').addEventListener('click', () => {
    // Show success dialog
    successDialog.classList.add('active');
    
    // Increment profile bookings
    userProfile.bookingsCount += 1;
    
    // Create new booking record
    const selectedTimeBtn = document.querySelector('.time-slot-btn.active');
    const priorityCheckEl = document.getElementById('priority-check');
    const newBooking = {
      id: 'b_' + Date.now(),
      barName: selectedBar ? selectedBar.name : 'Unknown Spot',
      userName: userProfile.name,
      time: selectedTimeBtn ? selectedTimeBtn.innerText : '21:00',
      guestCount: 2, // simulated guest count
      joinPriorityList: priorityCheckEl ? priorityCheckEl.checked : true,
      date: 'Oggi'
    };
    
    bookings.unshift(newBooking);
    saveData();
  });

  // Close success dialog and return to spots list
  document.getElementById('success-close-btn').addEventListener('click', () => {
    successDialog.classList.remove('active');
    bookingView.classList.remove('active');
    detailSheet.classList.remove('active');
    renderSpots();
  });

  // Open Profile View inside phone
  document.getElementById('profile-btn').addEventListener('click', () => {
    document.getElementById('prof-name').innerText = userProfile.name;
    document.getElementById('prof-username').innerText = userProfile.username;
    document.getElementById('prof-bookings-count').innerText = userProfile.bookingsCount;
    document.getElementById('prof-favorites-count').innerText = userProfile.favoritesCount;
    document.getElementById('prof-karma').innerText = userProfile.karma;
    
    profileView.classList.add('active');
  });

  // Logout inside simulator
  document.getElementById('prof-logout-btn').addEventListener('click', () => {
    if(confirm("Vuoi disconnetterti simulando il log out?")) {
      userProfile.bookingsCount = 0;
      userProfile.favoritesCount = 0;
      bars.forEach(b => b.isFavorite = false);
      saveData();
      
      profileView.classList.remove('active');
      detailSheet.classList.remove('active');
      bookingView.classList.remove('active');
      renderSpots();
      
      alert("Sessione pulita! I contatori del profilo sono stati azzerati.");
    }
  });

  // Navigation back buttons inside phone views
  document.getElementById('detail-back').addEventListener('click', () => {
    detailSheet.classList.remove('active');
    renderSpots();
  });

  document.getElementById('detail-fav-btn').addEventListener('click', () => {
    if (!selectedBar) return;
    selectedBar.isFavorite = !selectedBar.isFavorite;
    document.getElementById('detail-fav-btn').classList.toggle('active', selectedBar.isFavorite);
    userProfile.favoritesCount = bars.filter(b => b.isFavorite).length;
    saveData();
  });

  document.getElementById('booking-back').addEventListener('click', () => {
    bookingView.classList.remove('active');
  });

  document.getElementById('profile-back').addEventListener('click', () => {
    profileView.classList.remove('active');
  });

  // Open/Close review modal inside phone
  document.getElementById('detail-add-review-btn').addEventListener('click', () => {
    reviewModal.classList.add('active');
  });

  reviewModal.addEventListener('click', (e) => {
    if (e.target === reviewModal) {
      reviewModal.classList.remove('active');
    }
  });

  // Time Slots selection inside booking
  const slots = document.querySelectorAll('.time-slot-btn');
  slots.forEach(slot => {
    slot.addEventListener('click', () => {
      slots.forEach(s => s.classList.remove('active'));
      slot.classList.add('active');
    });
  });

  // RENDER LANDING PAGE BAR GRID
  function renderLandingGrid() {
    const landingGrid = document.getElementById('landing-spots-grid');
    if (!landingGrid) return;
    
    landingGrid.innerHTML = '';
    // Show top 3 bars based on rating
    const sorted = [...bars].sort((a,b) => b.rating - a.rating).slice(0, 3);
    
    sorted.forEach(bar => {
      const card = document.createElement('div');
      card.className = 'feature-card';
      
      let stars = '';
      for (let i=0; i<Math.floor(bar.rating); i++) {
        stars += '<span class="material-icons-round" style="font-size:12px; color:#ffb800">star</span>';
      }

      card.innerHTML = `
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
          <h4 style="font-size: 16px; font-weight:700;">${bar.name}</h4>
          <div style="display:flex; align-items:center; gap:4px; font-size:12px; font-weight:700;">
            ${stars}
            <span style="color:var(--text-grey); font-size:11px;">(${bar.rating})</span>
          </div>
        </div>
        <p style="font-size: 12px; color: var(--text-grey); line-height:1.5; margin-bottom:12px;">
          ${bar.description.substring(0, 70)}...
        </p>
        <div style="display:flex; justify-content:space-between; align-items:center; font-size:11px;">
          <span style="color: var(--primary-color); font-weight:600;">📍 ${bar.address.split(',')[0]}</span>
          <span style="background: rgba(0, 102, 255, 0.1); color: var(--primary-color); padding: 2px 8px; border-radius:10px; font-weight:700;">
            Live: ${bar.crowdDensity}%
          </span>
        </div>
      `;
      landingGrid.appendChild(card);
    });
  }

  // ==========================================
  // LOGICA DASHBOARD ADMIN
  // ==========================================

  const btnLanding = document.getElementById('btn-show-landing');
  const btnAdmin = document.getElementById('btn-show-admin');
  const viewLanding = document.getElementById('landing-main-view');
  const viewAdmin = document.getElementById('admin-dashboard-view');

  // Toggle View Click Listeners
  if (btnLanding && btnAdmin && viewLanding && viewAdmin) {
    btnLanding.addEventListener('click', () => {
      btnLanding.classList.add('active');
      btnAdmin.classList.remove('active');
      viewLanding.style.display = 'block';
      viewAdmin.style.display = 'none';
    });

    btnAdmin.addEventListener('click', () => {
      btnAdmin.classList.add('active');
      btnLanding.classList.remove('active');
      viewLanding.style.display = 'none';
      viewAdmin.style.display = 'block';
      renderAdminPanel();
    });
  }

  // Admin Tab Click Listeners
  const tabBtns = document.querySelectorAll('.admin-tab-btn');
  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      tabBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      
      const targetTab = btn.getAttribute('data-tab');
      document.querySelectorAll('.admin-tab-content').forEach(c => c.classList.remove('active'));
      document.getElementById('tab-' + targetTab).classList.add('active');
    });
  });

  // Render Admin Panel
  function renderAdminPanel() {
    // 1. Refresh stats badges
    const statBookings = document.getElementById('admin-stat-bookings');
    const statReviews = document.getElementById('admin-stat-reviews');
    const statBars = document.getElementById('admin-stat-bars');
    const statUsers = document.getElementById('admin-stat-users');

    // Count total reviews
    let totalReviewsCount = 0;
    bars.forEach(bar => {
      if (bar.reviews) totalReviewsCount += bar.reviews.length;
    });

    if (statBookings) statBookings.innerText = bookings.length;
    if (statReviews) statReviews.innerText = totalReviewsCount;
    if (statBars) statBars.innerText = bars.length;
    if (statUsers) statUsers.innerText = registeredUsers.length;

    // 2. Render Live Venue capacity controls
    const barsControlList = document.getElementById('admin-bars-control-list');
    if (barsControlList) {
      barsControlList.innerHTML = '';
      bars.forEach(bar => {
        const item = document.createElement('div');
        item.className = 'admin-bar-control-item';
        
        const isHigh = bar.crowdDensity > 80;
        
        item.innerHTML = `
          <div class="admin-bar-control-info">
            <div class="control-bar-name">${bar.name}</div>
            <div class="control-bar-type">${bar.type} • ${bar.vibeTags.join(', ')}</div>
          </div>
          <div class="admin-bar-control-actions">
            <div class="capacity-slider-wrapper">
              <input type="range" min="0" max="100" value="${bar.crowdDensity}">
              <span class="capacity-percent-badge ${isHigh ? 'high' : 'low'}">${bar.crowdDensity}%</span>
            </div>
          </div>
        `;

        const slider = item.querySelector('input[type="range"]');
        const badge = item.querySelector('.capacity-percent-badge');

        slider.addEventListener('input', (e) => {
          const val = parseInt(e.target.value);
          bar.crowdDensity = val;
          badge.innerText = `${val}%`;
          badge.className = `capacity-percent-badge ${val > 80 ? 'high' : 'low'}`;
          
          // Save and sync with local storage
          localStorage.setItem('spotit_madrid_bars', JSON.stringify(bars));
          
          // Re-render simulator components
          renderSpots();
          renderLandingGrid();
          
          // Update details sheet if currently viewing this bar
          if (selectedBar && selectedBar.id === bar.id) {
            document.getElementById('detail-density-txt').innerText = `${val}% di capacità`;
            document.getElementById('detail-density-bar').style.width = `${val}%`;
            document.getElementById('detail-density-bar').style.backgroundColor = val > 80 ? '#ff3366' : '#0066ff';
            
            // Also sync in-memory details
            selectedBar.crowdDensity = val;
          }
        });

        barsControlList.appendChild(item);
      });
    }

    // 3. Render Bookings Table
    const tableBookingsBody = document.getElementById('admin-table-bookings-body');
    if (tableBookingsBody) {
      tableBookingsBody.innerHTML = '';
      if (bookings.length === 0) {
        tableBookingsBody.innerHTML = `<tr><td colspan="5" style="text-align:center; color:var(--text-dark-grey);">Nessuna prenotazione attiva</td></tr>`;
      } else {
        bookings.forEach(b => {
          const isPri = b.joinPriorityList;
          const userAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=50&q=80';
          
          tableBookingsBody.innerHTML += `
            <tr>
              <td><strong>${b.barName}</strong></td>
              <td>
                <div class="avatar-cell">
                  <img class="table-avatar" src="${userAvatar}" alt="avatar">
                  <span>${b.userName}</span>
                </div>
              </td>
              <td>${b.date} • ${b.time}</td>
              <td style="text-align:center;">${b.guestCount}</td>
              <td>
                ${isPri ? '<span class="priority-tag">Prioritario</span>' : '<span class="no-priority-tag">Standard</span>'}
              </td>
            </tr>
          `;
        });
      }
    }

    // 4. Render Reviews Table
    const tableReviewsBody = document.getElementById('admin-table-reviews-body');
    if (tableReviewsBody) {
      tableReviewsBody.innerHTML = '';
      let hasReviews = false;
      
      bars.forEach(bar => {
        if (bar.reviews && bar.reviews.length > 0) {
          hasReviews = true;
          bar.reviews.forEach((rev, index) => {
            const row = document.createElement('tr');
            
            let starsHtml = '';
            for (let i = 1; i <= 5; i++) {
              starsHtml += `<span class="material-icons-round" style="font-size:10px; color:${i <= rev.rating ? '#ffb800' : 'var(--text-dark-grey)'}">star</span>`;
            }

            row.innerHTML = `
              <td><strong>${bar.name}</strong></td>
              <td>
                <div class="avatar-cell">
                  <img class="table-avatar" src="${rev.userAvatar}" alt="avatar">
                  <span>${rev.userName}</span>
                </div>
              </td>
              <td>${starsHtml}</td>
              <td style="max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${rev.comment}</td>
              <td>
                <button class="btn-delete-review" title="Elimina recensione">
                  <span class="material-icons-round" style="font-size: 14px;">delete</span>
                </button>
              </td>
            `;

            row.querySelector('.btn-delete-review').addEventListener('click', () => {
              if (confirm(`Eliminare la recensione di ${rev.userName} per ${bar.name}?`)) {
                bar.reviews.splice(index, 1);
                
                // Recalculate average rating
                bar.reviewCount = bar.reviews.length;
                if (bar.reviewCount > 0) {
                  const total = bar.reviews.reduce((sum, r) => sum + r.rating, 0);
                  bar.rating = parseFloat((total / bar.reviewCount).toFixed(1));
                } else {
                  bar.rating = 0.0;
                }
                
                saveData();
                renderSpots();
                if (selectedBar && selectedBar.id === bar.id) {
                  openDetailSheet(selectedBar);
                }
              }
            });

            tableReviewsBody.appendChild(row);
          });
        }
      });

      if (!hasReviews) {
        tableReviewsBody.innerHTML = `<tr><td colspan="5" style="text-align:center; color:var(--text-dark-grey);">Nessuna recensione presente</td></tr>`;
      }
    }

    // 5. Render Users Table
    const tableUsersBody = document.getElementById('admin-table-users-body');
    if (tableUsersBody) {
      tableUsersBody.innerHTML = '';
      registeredUsers.forEach(u => {
        const userAvatar = u.role === 'Amministratore' 
          ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=50&q=80'
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=50&q=80';
        
        tableUsersBody.innerHTML += `
          <tr>
            <td>
              <div class="avatar-cell">
                <img class="table-avatar" src="${userAvatar}" alt="avatar">
                <span><strong>${u.name}</strong></span>
              </div>
            </td>
            <td><span style="color: var(--primary-color); font-weight: 500;">${u.username}</span></td>
            <td>
              <span style="background: ${u.role === 'Amministratore' ? 'rgba(234, 88, 12, 0.1)' : 'rgba(255,255,255,0.03)'}; color: ${u.role === 'Amministratore' ? 'var(--accent-color)' : 'var(--text-grey)'}; padding: 2px 8px; border-radius: 8px; font-weight: 700; font-size: 10px;">
                ${u.role}
              </span>
            </td>
          </tr>
        `;
      });
    }
  }

  // Initial render
  renderSpots();
  renderLandingGrid();
  renderAdminPanel();
});
