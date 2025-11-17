### **Функциональные требования к системе**

1. **Профиль пользователя**
    - Создание аккаунта с подтверждением email
    - Восстановление забытого пароля
    - Добавление и редактирование личной информации (ФИО, контакты)
    - Добавление и редактирование платежной информации (банковские карты, электронные кошельки)
    - Настройка предпочтительных жанров книг для персональных рекомендаций
    - Отображение библиотеки купленных электронных книг
    - Хранения списка отложенных товаров
2. **Профиль продавца**
    - Добавление, редактирование и удаление товаров в каталоге
    - Добавление и отображение филиалов магазина
    - Сбор статистики по продажам, популярности товаров
3. **Каталог книг и других товаров**
    - Категории товаров (бумажные/электронные книги, канцтовары, товары для творчества и тд)
    - Подробное описание товара с характеристиками, ценами и изображениями
    - Добавление и удаление товаров в каталог
    - Наличие физических товаров на складе
    - Отображение рейтингов и отзывовов пользователей
    - Поиск и фильтрация товаров по различным параметрам (жанр, автор, издательство, цена, формат и тд)
4. **Корзина и оформление заказа**
    - Добавление товаров в корзину
    - Просмотр содержимого корзины пользователя с расчётом итоговой суммы заказа
    - Поддержка промокодов и скидок от сервиса
5. **Промокоды и скидки**
    - Добавление и удаление промокодов от сервиса
6. **Доставка и получение товаров**
    - Возможность выбора вариантов доставки для физических товаров (курьерская доставка, самовывоз)
    - Отслеживание статуса заказа (подтверждение, отправка, доставка, получение)
    - Возможность покупки и немедленного скачивания/чтения электронных версий книг через приложение
    - Отображение электронных книг в библиотеке пользователя после совершения покупки
7. **Возврат товаров**
    - Возможность оформления возврата физических товаров 
    - Отслеживание статуса возврата (заявка, ожидание отправления, ожидание возврата средств, завешено)
9. **Отзывы и рейтинги**
    - Возможность оставлять отзывы о купленных товарах
    - Отображение рейтинга товара на основе отзывов покупателей
10. **Персональные рекомендации и уведомления**
    - Рекомендации товаров на основе выбранных жанров и истории покупок
    - Настраиваемые уведомления о новых поступлениях, акциях и скидках

### Отношения

1. Пользователи, роли (клиент, продавец)
2. Контактная информация, адреса доставки
3. Библиотека электронных книг пользователя 
4. Пользовательская корзина
5. Список отложенных товаров 
6. Платёжная информация
7. Предпочтения пользователей (жанры, авторы, магазины, издатели)
8. Издатели 
9. Жанры 
10. Авторы
11. Магазины (название, адреса филиалов)
12. Каталог бумажных книг (магазин, описание, изображение, автор, издатель, жанр)
13. Каталог электронных книг (описание, автор, жанр, **формат**)
14. Категории других товаров товаров (магазин, описание, категория товара)
15. Наличие физических товаров на складе (id товара, категория товара, адрес склада, количество товаров в наличии)
16. Заказы, детали и содержание заказа, статусы доставки 
17. Заявки на возврат товаров
18. Акции с датами применения
19. История заказов
20. История возвратов
21. Отзывы и рейтинги

```plantuml
entity User {
* id : UUID
email : varchar(255)
password : varchar(255)
full_name : varchar(255)
role : text<enum<CLIENT, SELLER>>
}

entity ContactInfo {
* id : UUID
user_id : UUID
phone : varchar(30)
address : varchar(255)
}

entity PaymentMethod {
* id : UUID
user_id : UUID
type : text<enum<CARD, WALLET>>
account_number : varchar(255)
}

entity Wishlist {
* id : UUID
user_id : UUID
product_id : UUID
}

entity EBookLibrary {
* id : UUID
user_id : UUID
ebook_id : UUID
}

entity EbookFormat {
* id : UUID
format : text<enum<FB2, EPUB, PDF>>
}

entity Ebook {
* id : UUID
book_id : UUID
format_id : UUID
file_url : text 
}

entity CustomerGenrePreference {
user_id : UUID
genre_id : UUID
}

entity CustomerAuthorPreference {
user_id : UUID
author_id : UUID
}

entity CustomerShopPreference {
user_id : UUID
shop_id : UUID
}

entity CustomerPublisherPreference {
user_id : UUID
publisher_id : UUID
}

entity Genre {
* id : UUID
name : text
}

entity Author {
* id : UUID
name : varchar(255)
}

entity Publisher {
* id : UUID
name : varchar(255)
}

entity Shop {
* id : UUID
seller_id : UUID
name : varchar(255)
}

entity ShopBranch {
*id : UUID
shop_id : UUID
address : text
}

entity ProductCategory {
* id : UUID
name : varchar(255)
}

entity Product {
* id : UUID
name : varchar(255)
description : text
image_url : text
category_id : UUID
shop_id : UUID
price : decimal
}

entity BookInfo {
* id : UUID
product_id : UUID
author_id : UUID
genre_id : UUID
publisher_id : UUID
type : text<enum<PAPER, EBOOK>>
}

entity Inventory {
* id : UUID
product_id : UUID
store_branch_id : UUID
quantity : int
}

entity CartItem {
* id : UUID
user_id : UUID
product_id : UUID
quantity : int
}

entity OrderItem {
* id : UUID
user_id : UUID
order_id : UUID
product_id : UUID
price : decimal
}

entity Order {
* id : UUID
user_id : id
delivery_id : UUID
promocode_id : UUID
total_price : decimal
status : text<enum<PENDING, PAID, SHIPPED, SENT, DELIVERED>>
}

entity Delivery {
* id : UUID
address : text
}

entity Promocode {
* id : UUID
code : string
discount_percent : decimal
start_date : datetime
end_date : datetime
}

entity Review {
* id : UUID
user_id : UUID
product_id : UUID
raiting : int
text : text
}

entity ReturnRequest {
* id : UUID
user_id : UUID
order_id : UUID
product_id : UUID
return_reason : text
status : text<enum<REQUESTED, SHIPPED, CONFIRMED, COMPLETED>>
}

User ||--|| ContactInfo : has
User ||--|| PaymentMethod : has
User ||--|| Wishlist : owns
User ||--|| EBookLibrary : owns
User ||--o{ CartItem : adds
User ||--o{ Order : orders
User ||--o{ Review : leaves
User ||--o{ ReturnRequest : returns
User }o--o{ CustomerGenrePreference : prefers 
User }o--o{ CustomerAuthorPreference : prefers 
User }o--o{ CustomerPublisherPreference : prefers 
User }o--o{ CustomerShopPreference : prefers 

Ebook ||--|| EbookFormat : has
EBookLibrary  ||--o{ Ebook : has

CustomerGenrePreference ||--o{ Genre : has 
CustomerAuthorPreference ||--o{ Author : has
CustomerPublisherPreference ||--o{ Publisher : has
CustomerShopPreference ||--o{ Shop : has

BookInfo ||--|| Author : has
BookInfo ||--|| Genre : has
BookInfo ||--|| Publisher : has

BookInfo ||--|| Product : describes
Product  ||--|| ProductCategory : has
Product  ||--o{ Inventory : stocked_in

Shop ||--o{ ShopBranch : has
Shop ||--o{ Product : sells
Inventory ||--o{ ShopBranch : has

OrderItem ||--o{ Product : includes
Order ||--o{ OrderItem : includes
Order ||--o{ Delivery : includes
Order ||--o{ Promocode : might_use
```