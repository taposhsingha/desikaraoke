<!---

   1. 
      #### পুর্বশর্ত:
      #### যা করবেন:
      #### প্রত্যাশিত ফলাফল:
      #### পুনরাবৃত্তি:
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই
      #### বিদ্যমান সমস্যা:

--->

## Testing HELP

### কিভাবে Data clear করবেন?
বর্তমানে Desi Karaoke App এ লগ আউট করার ব্যবস্থা নেই। টেস্ট এর জন্য লগ ইন করলে App uninstall না করেও log out করা যায় Data clear এর মাধ্যমে। Data clear করতে হলে নিচ পদ্ধতি অনুসরণ করুন।

1. Desi Karaoke app এর icon এ tap করে ধরে রাখুন App info নামে একটি option আসবে। 
1. App info > Storage > CLEAR STORAGE/CLEAR DATA

অথবা,
1. Desi Karaoke app এর icon এ long press (সাধারণত ১ - ১.৫ সেকেন্ড)। তারপর icon টিকে সরানোর চেষ্টা করুন।
1. Screen এ উপরের দিকে `ⓘ App Info` option আসবে। icon টি `ⓘ App Info` এর উপরে নিয়ে ছেড়ে দিন।
1. Storage > CLEAR STORAGE/CLEAR DATA

অথবা,
1. Settings > Apps & Notification > All Apps > Desi Karaoke > Storage > CLEAR STORAGE/CLEAR DATA

অথবা,
1. Desi Karaoke app ওপেন থাকলে App switcher (▢ button) এ tap করুন। Desi Karaoke logo তে tap করে থাকুন। ⓘ icon এ tap করলে app info আসবে।
1. ⓘ > Storage > CLEAR STORAGE/CLEAR DATA

## Sign In and Cached Music
   1. Sign In
      #### পুর্বশর্ত:
      অ্যাপ এ লগইন থাকবে না। যদি log in করা অবস্থায় থাকে তাহলে Data clear করুন। (কিভাবে data clear করা হয় তা উপরে ব্যাখ্যা করা আছে।
      #### যা করবেন:
      1. App open করুন।
      1. Sign in with Google button এ tap করুন।
      1. যদি প্রয়োজন হয় তাহলে pop up থেকে আপনার Google Account টি সিলেক্ট করুন।
      #### প্রত্যাশিত ফলাফল:
      Log in screen টি চলে যাবে এবং Main screen দেখা যাবে।
      Log out থাকা অবস্থায় Main Screen দেখাবে না।
      #### পুনরাবৃত্তি:
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Cached music
      #### যা করবেন:
      App থেকে বের হয়ে যান back button (◀️) tap করে।
      পুনরায় App open করুন।
      #### প্রত্যাশিত ফলাফল:
      * App এ log in  করতে বলা হবে না। সরাসরি Main screen দেখাবে।
      * Song list load হতে পূর্বের থেকে অনেক কম সময় লাগবে। 
      #### পুনরাবৃত্তি:
      Song list load হওয়ার সময় পুনরায় পরীক্ষা করতে প্রথমে data clear করুন। তারপর আবার log in করুন।
      প্রথম বার song list load হতে সময় নেবে। কিন্তু পরের বার থেকে আর সময় নেবে না প্রথমবারের মতো।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

## Functionality Test

   1. App Launching
      #### পুর্বশর্ত:
      * অ্যাাপ এ লগইন থাকতে হবে।
      * Internet (WiFi/Mobile Data) চালু থাকতে হবে।
      #### যা করবেন:
      * Desi Karaoke App open করুন।
      #### প্রত্যাশিত ফলাফল:
      - অ্যাাপটি ঠিক মতো চালু হবে।
      - Desi Karaoke logo দেখাবে স্বল্প সময়ের জন্য।
      - লোগো চলে গিয়ে একটি Loading indicator দেখাবে।
      - Loading indicator টি চলে গিয়ে সব গানের লিস্ট দেখাবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

      # Main Screen
   1. Home List
      #### যা করবেন:
      * Main Screen এ নিচে দিকে থাকা navigation tab থেকে 'Home' select করুন।
      #### প্রত্যাশিত ফলাফল:
      * সব গানের লিস্ট দেখাবে। List এ গানের নামগুলো এবং Artist দের নামগুলো বাংলায় থাকবে।
      * List এ উপরে গানের নাম এবং নিচে ছোট অক্ষরে গানের Artist/Singer এর নাম লেখা থাকবে।
      * গানগুলো alphabetic order এ অর্থাৎ অ থেকে হ আকারে সাজানো থাকবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই
      #### বিদ্যমান সমস্যা:
      #38 [Home] Artist names should be displayed in Bengali

   1. Scrolling Home
      #### পুর্বশর্ত:
      * Main Screen এ 'Home' select করা থাকবে।
      #### যা করবেন:
      * গানের লিস্ট এ scroll করুন। ধীরে এবং দ্রুত।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Adding favorite
      #### যা করবেন:
      * Home এ থাকা গানে list থেকে কিছু গানের ডান দিকে থাকা favorite button (heart ♡ icon) এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      * favorite button টি লাল রঙ ধারণ করবে ❤️।
      * গানটি favorite list এ যোগ হবে যা navigation tab এর 'Favorite' এ tap করলে দেখা যাবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই


   1. Removing favorite
      #### যা করবেন:
      Favorite tab এ গিয়ে কিছু favorite গানের পাশের favorite button (red ❤️) এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      * লাল রঙের favorite button টি সাদা ♡ হয়ে যাবে।
      * navigation tab থেকে 'Favorite' এ tap করলে ওই গানটি/গানগুলো list থেকে চলে যাবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Remove favorite from Home
      #### যা করবেন:
      Home এ গানের list থেকে কিছু গান favorite করুন।
      #### প্রত্যাশিত ফলাফল:
      Favorite list এ গানগুলো দেখা যাবে।
      #### যা করবেন:
      Home এ ফিরে গিয়ে গানগুলো unfavorite করুন।
      #### প্রত্যাশিত ফলাফল:
      Favorite list এ গানগুলো আর দেখা যাবে না।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Artist list
      #### যা করবেন:
      * Main Screen থেকে 'Artist' select করুন।
      #### প্রত্যাশিত ফলাফল:
      * সব বাংলা গানের Artist এর নামের list দেখা যাবে। নামগুলো বাংলা অক্ষরে লেখা থাকবে।
      * নামগুলো alphabetic order এ অর্থাৎ অ থেকে হ আকারে সাজানো থাকবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই
      #### বিদ্যমান সমস্যা:
      #38 [Home] Artist names should be displayed in Bengali

   1. Song by Artist
      #### পুর্বশর্ত:
      * Main Screen এ 'Artist' select করা থাকবে।
      #### যা করবেন:
      * Artist list থেকে যেকোনো artist select করুন।
      #### প্রত্যাশিত ফলাফল:
      * যে artist select করেছেন তার বাংলা গানের লিস্ট দেখা যাবে।
      * কোন ক্ষেত্রেই লিস্ট খালি থাকবে না।
      #### যা করবেন:
      artist ভিত্তিক গানের list থেকে কিছু গান favorite করুন।
      #### প্রত্যাশিত ফলাফল:
      'Favorite' list এ গানগুলো দেখা যাবে।
      #### পুনরাবৃত্তি:
      কয়েকটি artist এর জন্য এই টেস্ট এর পুনরাবৃত্তি করুন।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Genre list
      #### যা করবেন:
      * Main Screen থেকে 'Genre' select করুন।
      #### প্রত্যাশিত ফলাফল:
      সব Genre'র list দেখা যাবে:
        1. Bangla Band
        1. Bangla Classic
        1. Bangla Modern
        1. Folk
        1. Hindi
        1. Kids Song
        1. Mother
        1. Nazrul Geeti
        1. Patriotic Song
        1. Tagore Song 
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Song by Genre
      #### পুর্বশর্ত:
      * Main Screen এ 'Genre' select করা থাকবে।
      #### যা করবেন:
      * Genre list থেকে যেকোনো genre select করুন।
      #### প্রত্যাশিত ফলাফল:
      * যে genre select করেছেন তার সব গানের লিস্ট দেখা যাবে।
      * কোন ক্ষেত্রেই লিস্ট খালি থাকবে না।
      #### যা করবেন:
      genre ভিত্তিক গানের list থেকে কিছু গান favorite করুন।
      #### প্রত্যাশিত ফলাফল:
      'Favorite' list এ গানগুলো দেখা যাবে।
      #### পুনরাবৃত্তি:
      কয়েকটি genre এর জন্য এই টেস্ট এর পুনরাবৃত্তি করুন।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই


   1. Language list
      #### যা করবেন:
      * Main Screen থেকে 'Language' select করুন।
      #### প্রত্যাশিত ফলাফল:
      সব Language এর list দেখা যাবে:
        1. Bangla
        1. Hindi
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Song by Language
      #### পুর্বশর্ত:
      * Main Screen এ 'Language' select করা থাকবে।
      #### যা করবেন:
      * Language list থেকে যেকোনো language select করুন।
      #### প্রত্যাশিত ফলাফল:
      * যে language select করেছেন তার সব গানের লিস্ট দেখা যাবে।
      * কোন ক্ষেত্রেই লিস্ট খালি থাকবে না।
      #### যা করবেন:
      language ভিত্তিক গানের list থেকে কিছু গান favorite করুন।
      #### প্রত্যাশিত ফলাফল:
      'Favorite' list এ গানগুলো দেখা যাবে।
      #### পুনরাবৃত্তি:
      উভয় language এর জন্য এই টেস্ট এর পুনরাবৃত্তি করুন।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

      # Karaoke Screen
   1. Music Playback
      #### যা করবেন:
      * Home list থেকে যেকোনো একটি গান সিলেক্ট করুন।
      #### প্রত্যাশিত ফলাফল:
      * Karaoke Screen আসবে। 
      * Screen এর উপরের দিকে select করা গানের নাম ও artist এর নাম থাকবে।
      * নিচের দিকে একটি stop button এবং একটি loading indicator থাকবে।
      * গান লোড হলে কয়েক second পরেই loading indicator এর পরিবর্তে play button দেখা যাবে।
      * Karaoke screen এ থাকাকালীন স্বতঃস্ফুর্তভাবে screen বন্ধ হবে না।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Music start
      #### যা করবেন:
      * play button এ ট্যাপ করুন।
      #### প্রত্যাশিত ফলাফল:
      * আপনার select করা গানটি শুরু হবে।
      * play button এর পরিবর্তে pause button আসবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Pause button and Play button
      #### পুর্বশর্ত:
      Karaoke Screen এ গান চলতে থাকবে।
      #### যা করবেন:
      * pause button এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      * গানটি থেমে যাবে।
      * pause button এর পরিবর্তে play button আসবে।
      #### পুনরাবৃত্তি:
      কয়েকবার play button ও pause button এ tap করে দেখুন প্রত্যাশিত ফলাফল আসছে কিনা।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Scale change
      #### পুর্বশর্ত:
      Karaoke Screen এ গান চলতে থাকবে।
      #### যা করবেন:
      Scale button এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      Scale পরিবর্তন করার option আসবে।
      #### যা করবেন:
      option থেকে ⊕ button ও ⊖ button চাপুন
      #### প্রত্যাশিত ফলাফল:
      * ⊕ button tap করলে গানের scale বৃদ্ধি পাবে, 
      এবং পাশে scale নির্দেশকারী সংখ্যাটি তা দেখাবে।
      * ⊖ button tap করলে গানের scale কমে যাবে, 
      এবং পাশে scale নির্দেশকারী সংখ্যাটি তা দেখাবে।
      * -6 থেকে +6 পর্যন্ত সবগুলো scale এর জন্য গানের স্বর পরিবর্তন হবে।
      #### যা করবেন:
      * Scale নির্দেশকারী slider এর মাধ্যমে scale পরিবর্তন করুন।
      #### প্রত্যাশিত ফলাফল:
      Scale পরিবর্তন হবে।
      #### যা করবেন:
      * Done button এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      * Scale পরিবর্তন করার option চলে যাবে।
      * পরিবর্তিত scale এ গান চলতে থাকবে।
      * Karaoke screen এ Scale button এর পাশে ব্রাকেটে বর্তমান scale দেখা যাবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Scale change cancel
      #### পুর্বশর্ত:
      Karaoke Screen এ গান চলতে থাকবে।
      #### যা করবেন:
      * Scale button এ tap করুন এবং ⊕ ⊖ button বা slider এর মাধ্যমে scale পরিবর্তন করুন।
      * cancel button এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      * scale পরিবর্তন করার option চলে যাবে।
      * scale পরিবর্তন করার পুর্বে যে scale এ গান চলছিল গান আবার ওই scale এ ফিরে যাবে।
      * Karaoke screen এ Scale button এর পাশে ব্রাকেটে পূর্বের scale দেখা যাবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Tempo change
      #### পুর্বশর্ত:
      Karaoke Screen এ গান চলতে থাকবে।
      #### যা করবেন:
      Tempo button এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      Tempo পরিবর্তন করার option আসবে।
      #### যা করবেন:
      option থেকে ⊕ button ও ⊖ button চাপুন
      #### প্রত্যাশিত ফলাফল:
      * ⊕ button tap করলে গানের tempo বা speed বৃদ্ধি পাবে, 
      এবং পাশে tempo নির্দেশকারী সংখ্যাটি তা দেখাবে।
      * ⊖ button tap করলে গানের tempo বা speed কমে যাবে, 
      এবং পাশে tempo নির্দেশকারী সংখ্যাটি তা দেখাবে।
      * -12 থেকে +12 পর্যন্ত সবগুলো tempo'র জন্য গানের speed পরিবর্তন হবে।
      * গানের lyric ঠিকমতো দেখাবে।
      #### যা করবেন:
      * Tempo নির্দেশকারী slider এর মাধ্যমে tempo পরিবর্তন করুন।
      #### প্রত্যাশিত ফলাফল:
      Tempo পরিবর্তন হবে।
      #### যা করবেন:
      * Done button এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      * Tempo পরিবর্তন করার option চলে যাবে।
      * পরিবর্তিত tempo এ গান চলতে থাকবে।
      * গানের সাথে lyric ঠিক থাকবে।
      * Karaoke screen এ Tempo button এর পাশে ব্রাকেটে বর্তমান tempo দেখা যাবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Tempo change cancel
      #### পুর্বশর্ত:
      Karaoke Screen এ গান চলতে থাকবে।
      #### যা করবেন:
      * Tempo button এ tap করুন এবং ⊕ ⊖ button বা slider এর মাধ্যমে tempo পরিবর্তন করুন।
      * cancel button এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      * tempo পরিবর্তন করার option চলে যাবে।
      * tempo পরিবর্তন করার পুর্বে যে tempo এ গান চলছিল গান আবার ওই tempo এ ফিরে যাবে।
      * Karaoke screen এ Tempo button এর পাশে ব্রাকেটে পূর্বের tempo দেখা যাবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   
   1. Background play
      #### পুর্বশর্ত:
      Karaoke Screen এ গান চলতে থাকবে।
      #### প্রত্যাশিত ফলাফল:
      * ফোনের screen lock থাকা অবস্থায় অথবা Desi Karaoke app background এ থাকা অবস্থায় গান paused হবে\হয়ে থাকবে।
      * Desi Karaoke app screen এ আনা হলে (forground) গান স্বতঃস্ফুর্তভাবে resumed হবে।
      * যদি background এ যাওয়া বা lock করার সময় গান paused অবস্থায় থাকে তাহলে পরবর্তিতে গান স্বতঃস্ফুর্তভাবে resumed হবে না।
      #### যা করবেন:
      গান চলতে থাকা অবস্থায় phone এর home (〇 button) এ tap করে app টি background এ পাঠান।
      #### প্রত্যাশিত ফলাফল:
      গান থেমে যাবে (paused)।
      #### যা করবেন:
      app switcher (▢ button) এর মাধ্যমে আবার Desi Karaoke app এ যান।
      #### প্রত্যাশিত ফলাফল:
      গান পূর্বের অবস্থান থেকে চলতে শুরু করবে।
      #### যা করবেন:
      গানটি pause করুন, pause button tap করুন।
      app টি background এ পাঠান।
      #### প্রত্যাশিত ফলাফল:
      গান থেমে থাকবে।
      #### যা করবেন:
      app switcher (▢ button) এর মাধ্যমে আবার Desi Karaoke app এ যান।
      #### প্রত্যাশিত ফলাফল:
      গানটি স্বতঃস্ফুর্তভাবে চালু হবে না।
      #### যা করবেন:
      play button এ tap করে গানটি resume করুন।
      #### প্রত্যাশিত ফলাফল:
      গান পূর্বের অবস্থান থেকে চলতে শুরু করবে।
      #### পুনরাবৃত্তি:
      * কয়েকবার এই test এর পুনরাবৃত্তি করুন
      * Background এ পাঠানোর মতো phone screen lock করার ক্ষেত্রেও একইভাবে test করুন।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই
      #### বিদ্যমান সমস্যা:

   1. Stop button
      #### পুর্বশর্ত:
      Karaoke Screen এ গান চলতে থাকবে।
      #### যা করবেন:
      stop button এ tap করুন।
      #### প্রত্যাশিত ফলাফল:
      * গানটি থেমে যাবে।
      * Karaoke Screen চলে যাবে।
      * আপনি karaoke screen এ আসার পূর্বে যে screen এ ছিলেন সেটা দেখা যাবে।
      #### পুনরাবৃত্তি:
      কয়েকবার stop button এ tap করে দেখুন প্রত্যাশিত ফলাফল আসছে কিনা।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই

   1. Auto stop & keep backlight
      #### পুর্বশর্ত:
      Karaoke screen এ গান চলতে থাকবে। (list থেকে যেকোন একটি গান select করে play করুন)
      #### যা করবেন:
      গান play করে অপেক্ষা করুন শেষ হওয়ার জন্য।
      screen এ touch করবেন না।
      #### প্রত্যাশিত ফলাফল:
      * গান এর শেষ পর্যন্ত সঠিক lyric দেখাবে।
      * screen স্বতঃস্ফুর্তভাবে বন্ধ হবে না।
      * গানটি শেষ হওয়ার সাথে সাথে karaoke screen চলে যাবে।
      * আপনি karaoke screen এ আসার পূর্বে যে screen এ ছিলেন সেটা দেখা যাবে।
      * এখন যদি আপনি কিচ্ছুক্ষণ screen এ tap না করেন তাহলে স্বতঃস্ফুর্তভাবে screen বন্ধ হবে।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই
   
   1. Repeatation for songs
      #### যা করবেন:
      এবার কমপক্ষে ৬টি গানের জন্য উপরের Karaoke screen এর অন্তর্গত সবগুলো টেস্ট করুন।
      * Music Playback
      * Music start
      * Pause button and Play button
      * Scale change
      * Scale change cancel
      * Tempo change
      * Tempo change cancel
      * Auto stop & keep backlight (২টি) / Stop button (৪টি)

      চেষ্টা করুন এমন কিছু করতে যাতে করে function গুলো ঠিক মতো কাজ না করে। অথবা Appটি crash করে।
      #### প্রত্যাশিত ফলাফল:
      * Karaoke screen এর প্রত্যেকটি function ঠিকমতো কাজ করবে।
      * Appটি crash করবে না।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই


   1. Exploratory test
      #### যা করবেন:
      উপরে উল্লেখিত নেই এমন ফিচারগুলো test করুন।
      * Search (Artist, title, বাংলা)
      * Search থেকে favorite করা এবং favorite বাদ দেওয়া।
      * Karaoke Screen এ back button (উপরে বাম দিকে 〈 icon)
      * Desi Karaoke device connected অবস্থায় playback.
      * Desi Karaoke device connected না থাকা অবস্থায় playback.
      * Desi Karaoke device কেনার contact number.
        +8801748332274
      * Sign up
      * Autoupdate for iOS and Android
      
      এবং অন্যান্য feature.
      #### প্রত্যাশিত ফলাফল:
      * feature গুলো ঠিকমতো কাজ করবে।
      * Appটি crash করবে না।
      #### ফলাফল:
      - [ ] ঠিক আছে
      - [ ] ঠিক নেই
