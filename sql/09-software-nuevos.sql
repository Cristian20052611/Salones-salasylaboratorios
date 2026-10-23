-- 09 · Software nuevo (logos adicionales). Ejecutar DESPUÉS de 08-software.sql.
-- Solo agrega al catálogo; NO se asignan a ningún salón (eso se hace desde el panel de administrador:
-- Software > salón con computadores > Editar). Se puede correr más de una vez sin duplicar nada.
insert into public.software(nombre, logo) values
  ('7-Zip', 'logos/7zip.svg'),
  ('Adobe After Effects', 'logos/adobeaftereffects.svg'),
  ('Adobe Creative Cloud', 'logos/adobecreativecloud.svg'),
  ('Adobe Illustrator', 'logos/adobeillustrator.svg'),
  ('Adobe InDesign', 'logos/adobeindesign.svg'),
  ('Adobe Photoshop', 'logos/adobephotoshop.svg'),
  ('Adobe Premiere Pro', 'logos/adobepremierepro.svg'),
  ('Anaconda', 'logos/anaconda.svg'),
  ('Apache NetBeans IDE', 'logos/apachenetbeanside.svg'),
  ('Arduino', 'logos/arduino.svg'),
  ('Autodesk', 'logos/autodesk.svg'),
  ('DBeaver', 'logos/dbeaver.svg'),
  ('diagrams.net', 'logos/diagramsdotnet.svg'),
  ('Kaspersky', 'logos/kaspersky.svg'),
  ('Odoo', 'logos/odoo.svg'),
  ('OpenJDK', 'logos/openjdk.svg'),
  ('Power BI', 'logos/powerbi.svg'),
  ('QGIS', 'logos/qgis.svg'),
  ('R', 'logos/r.svg'),
  ('RStudio', 'logos/rstudio.svg'),
  ('SQLite', 'logos/sqlite.svg'),
  ('Tableau', 'logos/tableau.svg'),
  ('Visual Studio', 'logos/visualstudio.svg'),
  ('VMware', 'logos/vmware.svg'),
  ('XAMPP', 'logos/xampp.svg')
on conflict (nombre) do nothing;
