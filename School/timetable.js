$(document).ready(() => {
    const time = $('.time')[0]
    const content1 = $('.content1')[0]
    const content2 = $('.content2')[0]
    if (time.childNodes.length > 2) {
        var index = 0
        time.childNodes.forEach((el) => {
            if (el.nodeName != '#text') {
                el.textContent = ''
            }
            if (index > 2 && el.nodeName != '#text') {
                el.remove()
            }
            index++
        })
    }

    const h1 = time.childNodes[1]
    const p1 = content1.childNodes[1]
    const p2 = content2.childNodes[1]
    const weekday = ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"];
    const monthday = ["Januari", "Febuari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"]
    const jadwal = {
        "Senin": ['PAI', 'B.Indonesia', 'B.Inggris', 'Fisika', 'BK'],
        "Selasa": ['Seni Budaya', 'LM1 (Ekonomi)', 'LM2 (B.Inggris)', 'Fisika', 'MTK Peminatan'],
        "Rabu": ['PKWU', 'Biologi', 'MTK Wajib', 'MTK Peminatan', 'B.Indonesia'],
        "Kamis": ['MTK Wajib', 'PJOK', 'PPKN', 'Sejarah Indonesia'],
        "Jumat": ['PAI', 'Kimia'],
        "Sabtu": ['None'],
        "Minggu": ['None']
    }

    var currentday = ''
    var nextday = ''
    var oldday = ''

    setInterval(() => {
        const date = new Date()
        var dates = [
            weekday[date.getDay()],
            monthday[date.getMonth()],
            date.getFullYear()
        ]
        h1.textContent = '[' + dates.join(', ') + ']'
        const calculate = (date.getDay() + 1) % weekday.length
        nextday = weekday[calculate]
        currentday = dates[0]
        if (oldday != currentday) {
            oldday = currentday
            p1.innerHTML = 'Jadwal Hari Ini<br><br>' + jadwal[currentday].join('<br>')
            p2.innerHTML = 'Jadwal Hari Besok<br><br>' + jadwal[nextday].join('<br>')
        }
    }, 100)
})