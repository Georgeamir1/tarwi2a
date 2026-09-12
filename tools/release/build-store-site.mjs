import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../../', import.meta.url));
const preview = process.argv.includes('--preview');
const configPath = process.argv.find((arg) => arg.startsWith('--config='))?.slice(9);
if (!preview && !configPath) throw new Error('Pass --config=store-site-config.json or --preview.');
const config = preview ? {
  businessName: '[اسم النشاط التجاري]', supportEmail: 'support@example.invalid',
  businessAddress: '[عنوان النشاط التجاري]',
  retentionPolicy: '[يحدد المالك البيانات المحتفظ بها، ومدتها، وأسباب الاحتفاظ، ومعاملة النسخ الاحتياطية]',
  deletionResponseTime: '[يحدد المالك المدة الفعلية لمعالجة طلبات الحذف]',
  cancellationPolicy: '[يحدد المالك شروط الإلغاء والاسترداد وطرق التواصل]',
} : JSON.parse(await readFile(resolve(configPath), 'utf8'));
for (const field of ['businessName', 'supportEmail', 'businessAddress', 'retentionPolicy', 'deletionResponseTime', 'cancellationPolicy']) {
  if (typeof config[field] !== 'string' || !config[field].trim()) throw new Error(`Missing owner information: ${field}`);
}
if (!preview && (!config.approvedForPublication || /example\.|\.invalid|\[/.test(config.supportEmail))) {
  throw new Error('Provide a real support email and approve the completed policy content before generating public pages.');
}
if (!/^[^\s<>@]+@[^\s<>@]+\.[^\s<>@]+$/.test(config.supportEmail)) throw new Error('Invalid support email.');
const escape = (value) => String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
const c = Object.fromEntries(Object.entries(config).map(([key, value]) => [key, escape(value)]));
const email = `<a href="mailto:${c.supportEmail}">${c.supportEmail}</a>`;
const contact = `<p>المسؤول عن تطبيق ترويئه: ${c.businessName}. العنوان: ${c.businessAddress}. للتواصل: ${email}.</p>`;
const pages = {
  'privacy-policy': ['سياسة الخصوصية', `${contact}
    <h2>البيانات التي نعالجها</h2><p>بيانات الحساب والاسم والبريد الإلكتروني ورقم الهاتف، وعناوين التوصيل وتفاصيلها والإحداثيات التي تقدمها، وسجل الطلبات والملاحظات وحالة الدفع والتقييمات. قد تشمل البيانات صوراً ترفعها، ومعرّفات الجهاز اللازمة لإشعارات الطلبات. إذا فُعّلت تقارير الأعطال، تُعالج بيانات التشخيص الفنية أيضاً.</p>
    <h2>أغراض الاستخدام ومقدمو الخدمة</h2><p>نستخدم البيانات لتسجيل الحساب وتنفيذ الطلبات والتوصيل والدعم والإشعارات وحماية الخدمة. نستعين بـ Supabase لتشغيل الحسابات والبيانات والتخزين، وبـ Firebase للإشعارات، وبـ Sentry عند تفعيل تقارير الأعطال. تظهر بيانات التوصيل للعاملين المخولين بتنفيذ طلبك. التعليقات التي تنشرها في قسم التقييمات قد تظهر لمستخدمي التطبيق.</p>
    <h2>خدمات خارجية</h2><p>عند اختيار إرسال إثبات دفع عبر WhatsApp أو فتح خدمة دفع خارجية، تنطبق أيضاً سياسة تلك الخدمة. لا يطلب التطبيق رقم بطاقتك المصرفية أو رمزها السري.</p>
    <h2>الاحتفاظ والحذف</h2><p>${c.retentionPolicy}</p><p>يمكنك طلب حذف حسابك وبياناته من إعدادات التطبيق أو من <a href="../delete-account/">صفحة حذف الحساب</a>. ${c.deletionResponseTime}</p>
    <h2>خياراتك</h2><p>يمكنك تعديل بياناتك، والتحكم في الإشعارات وأذونات الجهاز، والتواصل معنا لطلب الوصول إلى بياناتك أو تصحيحها أو حذفها.</p>`],
  'terms-of-service': ['الشروط والأحكام', `${contact}
    <h2>الحساب والطلبات</h2><p>قدّم بيانات صحيحة للتواصل والتوصيل، وحافظ على أمان حسابك. يخضع تنفيذ الطلب لتأكيد المطعم وتوفر المنتجات ومنطقة التوصيل. راجع المنتجات والرسوم وطريقة الدفع قبل تأكيد الطلب.</p>
    <h2>الأسعار والدفع</h2><p>يعرض التطبيق الأسعار بالجنيه المصري ورسوم التوصيل والخصم عند توفره. يراجع المطعم التحويلات المالية وإثبات الدفع قبل تأكيد استلام المبلغ.</p>
    <h2>الإلغاء والاسترداد</h2><p>${c.cancellationPolicy}</p>
    <h2>التقييمات والمحتوى</h2><p>يُحظر نشر التهديدات والإساءة والمحتوى غير القانوني أو بيانات الآخرين الشخصية. أرسل أي شكوى عن المحتوى إلى ${email} مع تفاصيل تساعدنا في مراجعته.</p>
    <h2>الدعم والخصوصية</h2><p>للمشكلات المتعلقة بالطلبات أو الحساب، تواصل معنا عبر <a href="../support/">صفحة الدعم</a>. توضح <a href="../privacy-policy/">سياسة الخصوصية</a> كيفية معالجة البيانات.</p>`],
  support: ['الدعم والتواصل', `${contact}<p>عند التواصل بشأن طلب، اذكر رقم الطلب ووصف المشكلة. لا ترسل كلمات المرور أو رموز التحقق أو بيانات البطاقة المصرفية.</p><p>لإزالة حسابك وبياناتك، اتبع <a href="../delete-account/">خطوات طلب حذف الحساب</a>.</p>`],
  'delete-account': ['حذف حساب ترويئه وبياناته', `${contact}
    <h2>من داخل التطبيق</h2><p>افتح الإعدادات، ثم اختر «طلب حذف الحساب»، واقرأ التأكيد وأكمل الخطوات الظاهرة.</p>
    <h2>بدون تثبيت التطبيق</h2><p>أرسل طلباً من البريد المسجل في حسابك إلى ${email} بعنوان «طلب حذف حساب ترويئه». إذا لم تعد تستطيع استخدام هذا البريد، تواصل معنا للتحقق من ملكية الحساب. لا ترسل كلمة المرور أو رمز التحقق.</p>
    <p><a class="button" href="mailto:${c.supportEmail}?subject=${encodeURIComponent('طلب حذف حساب ترويئه')}">فتح البريد لطلب حذف الحساب</a></p>
    <p>فتح برنامج البريد لا يرسل الطلب تلقائياً. راجع الرسالة وأرسلها لإيصال الطلب إلى فريق الدعم.</p>
    <h2>ما الذي يحدث للبيانات؟</h2><p>يشمل الطلب الحساب والملف الشخصي والعناوين والتقييمات وبيانات الإشعارات والملفات الشخصية المرتبطة به. ${c.retentionPolicy}</p><p>${c.deletionResponseTime}</p>`],
};
const css = 'body{margin:0;background:#faf7f2;color:#29251f;font:18px/1.85 system-ui,sans-serif}main{max-width:760px;margin:auto;padding:32px 20px}nav{display:flex;gap:18px;flex-wrap:wrap}a{color:#873c16}h1{font-size:2rem;line-height:1.4}h2{font-size:1.3rem;margin-top:32px}.button{display:inline-block;border:1px solid;padding:10px 18px;border-radius:8px}.draft{padding:16px;background:#fff0bf}footer{margin-top:40px;border-top:1px solid #ddd;padding-top:20px}a:focus-visible{outline:3px solid #873c16;outline-offset:4px}';
const output = resolve(root, 'build', preview ? 'store-site-preview' : 'store-site');
for (const [path, [title, body]] of Object.entries(pages)) {
  const directory = resolve(output, path);
  await mkdir(directory, { recursive: true });
  await writeFile(resolve(directory, 'index.html'), `<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">${preview ? '<meta name="robots" content="noindex,nofollow">' : ''}<title>${title} — ترويئه</title><style>${css}</style></head><body><main>${preview ? '<p class="draft">مسودة للمراجعة — معلومات المالك غير مكتملة. غير صالحة للنشر.</p>' : ''}<nav aria-label="صفحات الخدمة"><a href="../privacy-policy/">الخصوصية</a><a href="../terms-of-service/">الشروط</a><a href="../support/">الدعم</a><a href="../delete-account/">حذف الحساب</a></nav><h1>${title}</h1>${body}<footer>ترويئه · ${c.businessName}</footer></main></body></html>`, 'utf8');
}
console.log(`${preview ? 'Draft preview' : 'Owner-configured pages'}: ${output}`);
