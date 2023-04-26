---
title: "Bird Photography"
featuredImage: "/projects/bird-photography/white-ibis/20230407-3-banner.jpg"
summary: " "
draft: false
---

{{< rawhtml >}}
<script type="module">
	import PhotoSwipeLightbox from '/js/photoswipe-lightbox.esm.min.js';
	import PhotoSwipeDynamicCaption from '/js/photoswipe-dynamic-caption-plugin.esm.min.js';
	const lightbox = new PhotoSwipeLightbox({
	  gallery: '#bird-gallery--cropped-thumbs',
	  childSelector: '.pswp-gallery__item',
	  escKey: true,
	  arrowKeys: true,
	  initialZoomLevel: 'fit',
	  secondaryZoomLevel: 'fit',
	  maxZoomLevel: 'fit',
	  imageClickAction: 'close',
	  tapAction: 'close',
	  pswpModule: () => import('/js/photoswipe.esm.min.js')
	});

	const captionPlugin = new PhotoSwipeDynamicCaption(lightbox, {
		type: 'below',
		captionContent: '.pswp-caption-content'
	});

	let firstElWithBadge;
	let lastElWithBadge;

	// Gallery is starting to open
	lightbox.on('afterInit', () => {
	  firstElWithBadge = lightbox.pswp.currSlide.data.element;
	  hideBadge(firstElWithBadge);
	});

	// Gallery is starting to close
	lightbox.on('close', () => {
	  lastElWithBadge = lightbox.pswp.currSlide.data.element;
	  if(lastElWithBadge !== firstElWithBadge) {
		showBadge(firstElWithBadge);
		hideBadge(lastElWithBadge);
	  }
	});

	// Gallery is closed
	lightbox.on('destroy', () => {
		showBadge(lastElWithBadge);
	});

	lightbox.init();

	function hideBadge(el) {
	  el.querySelector('.lightbox-badge')
		.classList
		.add('lightbox-badge--hidden');
	};
	function showBadge(el) {
	  el.querySelector('.lightbox-badge')
		.classList
		.remove('lightbox-badge--hidden');
	}
</script>
<link rel="stylesheet" href="/css/photoswipe.css" />
<link rel="stylesheet" href="/css/photoswipe-dynamic-caption-plugin.css">

<div id="bird-gallery--cropped-thumbs" class="pswp-gallery">
{{% lightbox src="red-bellied-woodpecker/20230406-1.jpg" width="3039" height="2897" %}}
	A red-bellied woodpecker clutching the bottom of a large branch
	<br/> f/6.3, 1/400, 300mm, iso200
{{% /lightbox %}}

{{% lightbox src="yellow-crowned-night-heron/20230407-2.jpg" width="6000" height="4000" %}}
	A yellow-crowned night heron perched on a lichen-encrusted tree branch
	<br/> f/6.3, 1/125, 300mm, iso800
{{% /lightbox %}}

{{% lightbox src="cuban-grassquit/20230425-6.jpg" width="2688" height="3525" %}}
	A cuban grassquit atop a short branch, looking into the camera
	<br/> f/6.3, 1/640, 300mm, iso400
{{% /lightbox %}}

{{% lightbox src="tricolored-heron/20230407-2.jpg" width="4536" height="3345" %}}
	A tricolored heron standing on the roots of a mangrove tree
	<br/> f/4.8, 1/400, 100mm, iso800
{{% /lightbox %}}

{{% lightbox src="osprey/20230413-2.jpg" width="6000" height="4000" %}}
	An osprey soaring against a cloudy background
	<br/> f/16, 1/500, 210mm, iso400
{{% /lightbox %}}
</div>
{{< /rawhtml >}}
