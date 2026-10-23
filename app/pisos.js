(function(){
  var obs=null;

  function floorOf(code){
    var m=String(code||'').match(/\d{3,}/);
    if(!m) return null;
    return Number.parseInt(m[0].slice(0,m[0].length-2),10);
  }

  function codeNum(card){
    var el=card.querySelector('.room-code');
    var m=String(el?el.textContent:'').match(/\d+/);
    return m?Number.parseInt(m[0],10):0;
  }

  function buildGrid(grid){
    var cards=Array.prototype.slice.call(grid.querySelectorAll('.room-card'));
    if(!cards.length) return;
    var loose=Array.prototype.some.call(grid.children,function(c){
      return c.classList&&c.classList.contains('room-card');
    });
    if(grid.querySelector('.floor-section')&&!loose) return;

    var groups={};
    cards.forEach(function(c){
      var el=c.querySelector('.room-code');
      var f=floorOf(el?el.textContent:'');
      var k=(f===null)?'x':String(f);
      if(!groups[k]) groups[k]=[];
      groups[k].push(c);
    });

    var keys=Object.keys(groups).sort(function(a,b){
      if(a==='x') return 1;
      if(b==='x') return -1;
      return Number.parseInt(a,10)-Number.parseInt(b,10);
    });

    grid.classList.add('por-pisos');
    grid.textContent='';

    keys.forEach(function(k){
      var list=groups[k].sort(function(a,b){return codeNum(a)-codeNum(b);});
      var sec=document.createElement('section');
      sec.className='floor-section';

      var h=document.createElement('h3');
      h.className='floor-title';
      var num=document.createElement('span');
      num.className='floor-num';
      num.textContent=(k==='x')?'+':k;
      var name=document.createElement('span');
      name.textContent=(k==='x')?'Otros espacios':'Piso '+k;
      var count=document.createElement('small');
      count.textContent=list.length+(list.length===1?' salón':' salones');
      h.appendChild(num);
      h.appendChild(name);
      h.appendChild(count);

      var wrap=document.createElement('div');
      wrap.className='floor-cards';
      list.forEach(function(c){wrap.appendChild(c);});

      sec.appendChild(h);
      sec.appendChild(wrap);
      grid.appendChild(sec);
    });
  }

  function tagTable(){
    document.querySelectorAll('.coord-table tbody tr').forEach(function(tr){
      var td=tr.children[0];
      if(!td||td.getAttribute('data-piso')) return;
      var t=td.textContent.trim();
      if(/^\d{3,}$/.test(t)){
        td.setAttribute('data-piso','Piso '+floorOf(t));
      }
    });
  }

  function run(){
    if(obs) obs.disconnect();
    try{
      document.querySelectorAll('.room-grid').forEach(buildGrid);
      tagTable();
    }catch(e){ /* si falla el agrupado, las tarjetas se ven sin agrupar */ }
    if(obs) obs.observe(document.body,{childList:true,subtree:true});
  }

  function init(){
    obs=new MutationObserver(run);
    run();
  }

  if(document.readyState==='loading'){
    document.addEventListener('DOMContentLoaded',init);
  }else{
    init();
  }
})();
