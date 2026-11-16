import random
from datetime import timedelta
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.db import transaction
from django.contrib.auth import get_user_model
from apps.users.models import VolunteerProfile, NGOProfile
from apps.events.models import Event, EventRegistration
from apps.initiatives.models import Initiative
from apps.reviews.models import Review
from apps.notifications.models import Notification

User = get_user_model()

class Command(BaseCommand):
    help = 'Seeds the database with realistic test data'

    def handle(self, *args, **options):
        self.stdout.write('Seeding data...')
        
        try:
            with transaction.atomic():
                self.clear_data()
                self.create_ngos()
                self.create_volunteers()
                self.create_events()
                self.create_registrations_and_reviews()
                self.create_initiatives()
                self.create_notifications()
                
            self.stdout.write(self.style.SUCCESS('Successfully seeded database!'))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'Seeding failed: {e}'))

    def clear_data(self):
        self.stdout.write('Clearing existing data...')
        # Delete in order to avoid foreign key issues
        Review.objects.all().delete()
        Notification.objects.all().delete()
        EventRegistration.objects.all().delete()
        Initiative.objects.all().delete()
        Event.objects.all().delete()
        NGOProfile.objects.all().delete()
        VolunteerProfile.objects.all().delete()
        # Keep superusers if any
        User.objects.filter(is_superuser=False).delete()

    def create_ngos(self):
        self.stdout.write('Creating NGOs...')
        ngos_data = [
            {
                'username': 'eco_movement',
                'first_name': 'ЭкоДвижение',
                'last_name': 'Кыргызстана',
                'email': 'eco@kg.org',
                'org_name': 'ЭкоДвижение КР',
                'description': 'Мы заботимся о природе Кыргызстана. Проводим субботники, сажаем деревья и просвещаем жителей.',
                'location': 'Бишкек',
            },
            {
                'username': 'red_crescent',
                'first_name': 'Красный',
                'last_name': 'Полумесяц',
                'email': 'info@redcrescent.kg',
                'org_name': 'Красный Полумесяц КР',
                'description': 'Гуманитарная организация, помогающая в кризисных ситуациях и организующая дни донора.',
                'location': 'Бишкек',
            },
            {
                'username': 'it_volunteers',
                'first_name': 'IT',
                'last_name': 'Волонтеры',
                'email': 'hello@itvol.kg',
                'org_name': 'IT-Волонтеры КР',
                'description': 'Сообщество разработчиков, помогающее социальным проектам и обучающее цифровой грамотности.',
                'location': 'Бишкек/Ош',
            },
        ]

        for data in ngos_data:
            user = User.objects.create_user(
                username=data['username'],
                email=data['email'],
                password='password123',
                first_name=data['first_name'],
                last_name=data['last_name'],
                role='ngo',
                location=data['location'],
                is_verified=True
            )
            NGOProfile.objects.get_or_create(
                user=user,
                org_name=data['org_name'],
                description=data['description'],
                contact_email=data['email']
            )

    def create_volunteers(self):
        self.stdout.write('Creating Volunteers...')
        volunteers_data = [
            {
                'username': 'aibek_hero',
                'first_name': 'Айбек',
                'last_name': 'Осмонов',
                'bio': 'Люблю природу и помогать людям. Мечтаю сделать наш город чище.',
                'skills': ['Экология', 'Педагогика', 'IT'],
                'location': 'Бишкек',
            },
            {
                'username': 'meerim_care',
                'first_name': 'Мээрим',
                'last_name': 'Асанова',
                'bio': 'Студентка-медик, готова помогать в госпиталях и на днях донора.',
                'skills': ['Медицина', 'Психология'],
                'location': 'Ош',
            },
            {
                'username': 'bakyt_dev',
                'first_name': 'Бакыт',
                'last_name': 'Исаев',
                'bio': 'Разработчик, хочу применять свои навыки для социального блага.',
                'skills': ['Python', 'Flutter', 'Преподавание'],
                'location': 'Бишкек',
            },
        ]

        for data in volunteers_data:
            user = User.objects.create_user(
                username=data['username'],
                email=f"{data['username']}@test.com",
                password='password123',
                first_name=data['first_name'],
                last_name=data['last_name'],
                role='volunteer',
                location=data['location']
            )
            VolunteerProfile.objects.get_or_create(
                user=user,
                bio=data['bio'],
                skills=data['skills']
            )

    def create_events(self):
        self.stdout.write('Creating Events...')
        eco_ngo = User.objects.get(username='eco_movement')
        red_ngo = User.objects.get(username='red_crescent')
        it_ngo = User.objects.get(username='it_volunteers')

        events_data = [
            {
                'title': 'Субботник в парке Ата-Тюрк',
                'description': 'Приглашаем всех жителей присоединиться к очистке нашего любимого парка.',
                'category': 'ecology',
                'organizer': eco_ngo,
                'location': 'Бишкек, Парк Ата-Тюрк',
                'hours': 4,
                'spots_total': 20,
                'is_urgent': True,
                'image_name': 'ecology_cover.png',
            },
            {
                'title': 'День донора',
                'description': 'Сбор крови для Национального Центра Кардиологии.',
                'category': 'health',
                'organizer': red_ngo,
                'location': 'Бишкек, ул. Логвиненко 8',
                'hours': 2,
                'spots_total': 50,
                'is_urgent': False,
                'image_name': 'health_cover.png',
            },
            {
                'title': 'Курсы компьютерной грамотности для детей',
                'description': 'Помогаем детям из детских домов освоить азы работы с ПК.',
                'category': 'education',
                'organizer': it_ngo,
                'location': 'Ош, ул. Ленина 120',
                'hours': 3,
                'spots_total': 10,
                'is_urgent': False,
                'image_name': 'education_cover.png',
            },
        ]

        for data in events_data:
            image_name = data.pop('image_name')
            event = Event.objects.create(
                **data,
                date=timezone.now() + timedelta(days=random.randint(2, 10)),
                type='offline'
            )
            # Link image if it exists in DB (simulated via path since it's ImageField)
            event.image = f'events/{image_name}'
            event.save()

    def create_registrations_and_reviews(self):
        self.stdout.write('Creating Registrations and Reviews...')
        volunteers = User.objects.filter(role='volunteer')
        events = Event.objects.all()

        for vol in volunteers:
            # Register for some events
            selected_events = random.sample(list(events), 2)
            for event in selected_events:
                status = random.choice(['approved', 'pending', 'attended'])
                EventRegistration.objects.create(
                    event=event,
                    volunteer=vol,
                    status=status
                )
                
                # If attended, create a review
                if status == 'attended':
                    Review.objects.create(
                        reviewer=event.organizer,
                        target_user=vol,
                        event=event,
                        rating=5,
                        text="Отличный волонтер! Очень ответственный.",
                        is_from_ngo=True
                    )
                    vol.total_hours += event.hours
                    vol.rating = 5.0
                    vol.save()

    def create_initiatives(self):
        self.stdout.write('Creating Initiatives...')
        vol = User.objects.get(username='aibek_hero')
        
        Initiative.objects.create(
            title='Уборка на Иссык-Куле',
            description='Собрал 10 мешков мусора в районе Бостери.',
            author=vol,
            category='ecology',
            location='Иссык-Куль, Бостери',
            hours_claimed=5,
            status='approved'
        )
        vol.total_hours += 5
        vol.save()

    def create_notifications(self):
        self.stdout.write('Creating Notifications...')
        vol = User.objects.get(username='aibek_hero')
        
        Notification.objects.create(
            user=vol,
            title='🌟 Вас похвалили!',
            body='ЭкоДвижение КР оставило вам оценку 5 звезд.',
            type='system'
        )
        Notification.objects.create(
            user=vol,
            title='📅 Новое событие!',
            body='IT-Волонтеры приглашают вас на курсы в Оше.',
            type='invitation'
        )
