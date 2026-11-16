from django.core.management.base import BaseCommand
from django.utils import timezone
from apps.users.models import CustomUser, VolunteerProfile, NGOProfile
from apps.events.models import Event, EventRegistration
from apps.initiatives.models import Initiative
from apps.reviews.models import Review
from datetime import timedelta


class Command(BaseCommand):
    help = 'Create test data for development'

    def handle(self, *args, **options):
        self.stdout.write('Creating test data...')

        # Create volunteers
        volunteer1 = CustomUser.objects.create_user(
            username='aibek_volunteer',
            email='aibek@example.com',
            password='test1234',
            first_name='Айбек',
            last_name='Токтогулов',
            role='volunteer',
            location='Бишкек, Кыргызстан',
            total_hours=45,
            rating=4.8,
            email_verified=True
        )
        VolunteerProfile.objects.create(
            user=volunteer1,
            skills=['Экология', 'Работа с детьми'],
            bio='Активный волонтер, люблю помогать природе и детям'
        )

        volunteer2 = CustomUser.objects.create_user(
            username='gulnara_volunteer',
            email='gulnara@example.com',
            password='test1234',
            first_name='Гульнара',
            last_name='Асанова',
            role='volunteer',
            location='Ош, Кыргызстан',
            total_hours=32,
            rating=4.5,
            email_verified=True
        )
        VolunteerProfile.objects.create(
            user=volunteer2,
            skills=['IT-волонтерство', 'Образование'],
            bio='Программист, помогаю с IT-проектами'
        )

        volunteer3 = CustomUser.objects.create_user(
            username='bektur_volunteer',
            email='bektur@example.com',
            password='test1234',
            first_name='Бектур',
            last_name='Мамытов',
            role='volunteer',
            location='Каракол, Кыргызстан',
            total_hours=18,
            rating=4.2,
            email_verified=True
        )
        VolunteerProfile.objects.create(
            user=volunteer3,
            skills=['Спорт', 'Молодежь'],
            bio='Тренер, работаю с молодежью'
        )

        # Create NGOs
        ngo1 = CustomUser.objects.create_user(
            username='eco_kg',
            email='info@eco.kg',
            password='test1234',
            first_name='Эко',
            last_name='Кыргызстан',
            role='ngo',
            location='Бишкек, Кыргызстан',
            rating=4.9,
            is_verified=True,
            email_verified=True
        )
        NGOProfile.objects.create(
            user=ngo1,
            org_name='Эко Кыргызстан',
            description='Экологическая организация, занимающаяся охраной природы',
            contact_email='info@eco.kg',
            website='https://eco.kg'
        )

        ngo2 = CustomUser.objects.create_user(
            username='help_children',
            email='info@helpchildren.kg',
            password='test1234',
            first_name='Помощь',
            last_name='Детям',
            role='ngo',
            location='Бишкек, Кыргызстан',
            rating=4.7,
            is_verified=True,
            email_verified=True
        )
        NGOProfile.objects.create(
            user=ngo2,
            org_name='Помощь детям Кыргызстана',
            description='Благотворительная организация для помощи детям',
            contact_email='info@helpchildren.kg',
            website='https://helpchildren.kg'
        )

        self.stdout.write(self.style.SUCCESS('✓ Created users'))

        # Create events
        event1 = Event.objects.create(
            title='Уборка парка "Ата-Тюрк"',
            description='Приглашаем всех желающих на уборку парка. Принесите перчатки и мешки для мусора.',
            organizer=ngo1,
            category='ecology',
            date=timezone.now() + timedelta(days=3),
            end_time=timezone.now() + timedelta(days=3, hours=4),
            location='Парк Ата-Тюрк, Бишкек',
            latitude=42.8746,
            longitude=74.5698,
            type='offline',
            hours=4,
            spots_total=50,
            status='open',
            is_urgent=False
        )

        event2 = Event.objects.create(
            title='Онлайн-тренинг по экологии',
            description='Обучающий вебинар о сохранении природы и экологических проблемах Кыргызстана.',
            organizer=ngo1,
            category='education',
            date=timezone.now() + timedelta(days=5),
            end_time=timezone.now() + timedelta(days=5, hours=2),
            location='Онлайн (Zoom)',
            type='online',
            hours=2,
            spots_total=100,
            status='open',
            is_urgent=False
        )

        event3 = Event.objects.create(
            title='Помощь детскому дому',
            description='Нужны волонтеры для организации праздника для детей. Будем играть, рисовать и веселиться!',
            organizer=ngo2,
            category='children',
            date=timezone.now() + timedelta(days=7),
            end_time=timezone.now() + timedelta(days=7, hours=5),
            location='Детский дом №3, Бишкек',
            latitude=42.8654,
            longitude=74.5832,
            type='offline',
            hours=5,
            spots_total=20,
            status='open',
            is_urgent=True
        )

        event4 = Event.objects.create(
            title='Посадка деревьев в Ала-Арче',
            description='Массовая акция по посадке деревьев в национальном парке Ала-Арча.',
            organizer=ngo1,
            category='ecology',
            date=timezone.now() + timedelta(days=10),
            end_time=timezone.now() + timedelta(days=10, hours=6),
            location='Национальный парк Ала-Арча',
            latitude=42.5833,
            longitude=74.4833,
            type='offline',
            hours=6,
            spots_total=100,
            status='open',
            is_urgent=False
        )

        self.stdout.write(self.style.SUCCESS('✓ Created events'))

        # Create event registrations
        EventRegistration.objects.create(event=event1, volunteer=volunteer1, status='approved')
        EventRegistration.objects.create(event=event1, volunteer=volunteer2, status='approved')
        EventRegistration.objects.create(event=event3, volunteer=volunteer1, status='approved')
        EventRegistration.objects.create(event=event3, volunteer=volunteer3, status='approved')

        self.stdout.write(self.style.SUCCESS('✓ Created event registrations'))

        # Create initiatives
        initiative1 = Initiative.objects.create(
            title='Уборка берега реки Чу',
            description='Собрал группу друзей и убрали мусор на берегу реки Чу. Собрали 15 мешков мусора!',
            author=volunteer1,
            category='ecology',
            location='Река Чу, село Беловодское',
            latitude=42.8333,
            longitude=75.1167,
            hours_claimed=3,
            before_photos=['https://example.com/before1.jpg'],
            after_photos=['https://example.com/after1.jpg'],
            status='approved'
        )

        initiative2 = Initiative.objects.create(
            title='Помощь пожилой соседке',
            description='Помог соседке с покупками и уборкой дома.',
            author=volunteer2,
            category='elderly',
            location='Ош, микрорайон Аэропорт',
            latitude=40.5283,
            longitude=72.7985,
            hours_claimed=2,
            before_photos=['https://example.com/before2.jpg'],
            after_photos=['https://example.com/after2.jpg'],
            status='approved'
        )

        initiative3 = Initiative.objects.create(
            title='Ремонт детской площадки',
            description='Отремонтировали качели и покрасили скамейки на детской площадке.',
            author=volunteer3,
            category='children',
            location='Каракол, микрорайон Центр',
            latitude=42.4906,
            longitude=78.3947,
            hours_claimed=5,
            before_photos=['https://example.com/before3.jpg'],
            after_photos=['https://example.com/after3.jpg'],
            status='pending'
        )

        self.stdout.write(self.style.SUCCESS('✓ Created initiatives'))

        # Create reviews
        Review.objects.create(
            reviewer=ngo1,
            target_user=volunteer1,
            event=event1,
            rating=5,
            text='Отличный волонтер! Очень ответственный и активный.',
            is_from_ngo=True
        )

        Review.objects.create(
            reviewer=volunteer1,
            target_user=ngo1,
            event=event1,
            rating=5,
            text='Прекрасная организация мероприятия, все было четко и понятно.',
            is_from_ngo=False
        )

        Review.objects.create(
            reviewer=ngo2,
            target_user=volunteer1,
            event=event3,
            rating=5,
            text='Замечательно работает с детьми, очень добрый и внимательный.',
            is_from_ngo=True
        )

        Review.objects.create(
            reviewer=volunteer2,
            target_user=ngo1,
            event=event2,
            rating=4,
            text='Хороший тренинг, но хотелось бы больше практических примеров.',
            is_from_ngo=False
        )

        self.stdout.write(self.style.SUCCESS('✓ Created reviews'))

        self.stdout.write(self.style.SUCCESS('\n=== Test data created successfully! ==='))
        self.stdout.write(self.style.SUCCESS('\nTest accounts:'))
        self.stdout.write('Volunteers:')
        self.stdout.write('  - aibek_volunteer / test1234')
        self.stdout.write('  - gulnara_volunteer / test1234')
        self.stdout.write('  - bektur_volunteer / test1234')
        self.stdout.write('\nNGOs:')
        self.stdout.write('  - eco_kg / test1234')
        self.stdout.write('  - help_children / test1234')
