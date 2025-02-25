--Задание 1/Выведите сколько пользователей добавили книгу 'Coraline', сколько пользователей прослушало больше 10%.

-- Запрос для определения количества пользователей, которые добавили книгу 'Coraline'
SELECT COUNT(DISTINCT ac.user_id) AS users_added
FROM audio_cards ac
JOIN audiobooks ab ON ac.audiobook_uuid = ab.uuid
WHERE ab.title = 'Coraline';

-- Запрос для определения количества пользователей, которые прослушали книгу 'Coraline' более чем на 10%
SELECT COUNT(DISTINCT l.user_id) AS users_listened_more_than_10_percent
FROM listenings l
JOIN audiobooks ab ON l.audiobook_uuid = ab.uuid
WHERE ab.title = 'Coraline' AND (l.position_to - l.position_from) >= 0.1 * ab.duration;

--Задание 2/По каждой операционной системе и названию книги выведите количество пользователей, сумму прослушивания в часах, не учитывая тестовые прослушивания. 
SELECT 
    l.os_name AS operating_system,
    a.title AS book_title,
    COUNT(DISTINCT l.user_id) AS user_count,
    SUM((l.position_to - l.position_from) / 3600.0) AS total_listening_hours
FROM listenings l
JOIN audiobooks a 
ON l.audiobook_uuid = a.uuid
WHERE l.is_test = 0
GROUP BY l.os_name, a.title
ORDER BY l.os_name, a.title;

--Задание 3/Найдите книгу, которую слушает больше всего людей
SELECT 
   	 a.title, 
    		COUNT(DISTINCT l.user_id) AS num_users
FROM listenings l
JOIN audiobooks a ON l.audiobook_uuid = a.uuid
GROUP BY a.title
ORDER BY num_users DESC
LIMIT 1;

--Задание 4/Найдите книгу, которую чаще всего дослушивают до конца.
SELECT 
    a.title, 
    COUNT(l.id) AS completed_listens
FROM 
    listenings l
JOIN 
    audiobooks a ON l.audiobook_uuid = a.uuid
WHERE 
    EXTRACT(EPOCH FROM (l.finished_at - l.started_at)) >= a.duration    --EXTRACT(EPOCH FROM преобразует этот интервал в количество секунд.
GROUP BY 
    a.title
ORDER BY 
    completed_listens DESC
LIMIT 1;

