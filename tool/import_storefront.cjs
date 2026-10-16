// Refresh editorial content from the existing storefront. Prices and stock stay API-driven.
const fs = require('fs');
const path = require('path');
const cheerio = require(process.env.CHEERIO_MODULE || 'cheerio');
const source = process.env.STOREFRONT_REFERENCE;
if (!source) throw Error('Set STOREFRONT_REFERENCE to the existing reference asset directory.');
const output = path.resolve(__dirname, '../assets/content');
const artwork = path.resolve(__dirname, '../assets/brand/site');
fs.mkdirSync(output, {recursive:true});
const clean = text => text.replace(/\s+/g,' ').trim();
(async()=>{
 const catalog = await (await fetch('https://nmdiet.ru/api/mobile/v1/products')).json();
 const result = {};
 for (const p of catalog.data) {
  const $=cheerio.load(await (await fetch(`https://nmdiet.ru/secret/products/${p.slug}`)).text());
  const hero=$('main section').first();
  const subtitle=clean(hero.find('[class$="info__subtitle"], [class$="hero__subtitle"]').first().text());
  const concept=clean(hero.find('[class$="concept__title"]').first().text());
  const sections=[];
  $('main section, main .nmd-brand-story').each((_,section)=>{
   const s=$(section), cls=s.attr('class')||'';
   if(s.is(hero)||/hero|ozon-delivery|reviews/.test(cls)) return;
   const title=clean(s.find('h2').first().text());if(!title)return;
   const blocks=[];
   const selectors='h3,p,li,tr,.nmd-component,.nmd-formula__dose-note,[class$="__card-main"],[class$="__important-title"],.nmd-one-formula__separate,.nmd-one-formula__tiro,.nmd-one-formula__final';
   s.find(selectors).each((_,node)=>{
    const e=$(node);if(e.parentsUntil(section).filter(selectors).length)return;
    if(e.hasClass('nmd-component')){
     blocks.push({kind:'component',title:clean(e.find('.nmd-component__name').text()),text:clean(e.find('.nmd-component__form').text()),value:clean(e.find('.nmd-component__dose').text())});return;
    }
    const text=clean(e.text());if(text)blocks.push({kind:e.is('h3')||e.is('[class$="__card-main"],[class$="__important-title"]')?'heading':e.is('.nmd-one-formula__separate,.nmd-one-formula__tiro,.nmd-one-formula__final')?'panel':'text',text});
   });
   const images=[];s.find('img').each((_,node)=>{
    const src=$(node).attr('src')||'',filename=path.basename(src);
    if(!src.includes('/storefront/reference/')||!fs.existsSync(path.join(source,filename)))return;
    fs.copyFileSync(path.join(source,filename),path.join(artwork,filename));
    images.push({asset:`assets/brand/site/${filename}`,alt:$(node).attr('alt')||''});
   });
   const eyebrow=clean(s.find('[class$="__eyebrow"]').first().text());
   sections.push({title,eyebrow,blocks,images});
  });
  result[p.slug]={subtitle,concept,sections};console.log(p.slug,sections.length);
 }
 fs.writeFileSync(path.join(output,'product_stories.json'),JSON.stringify(result,null,2)+'\n');
})().catch(e=>{console.error(e);process.exitCode=1});
