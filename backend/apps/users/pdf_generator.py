from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from io import BytesIO
from django.utils import timezone


def generate_volunteer_book_pdf(user):
    """
    Generate volunteer book PDF for a user.

    Args:
        user: User instance (volunteer)

    Returns:
        BytesIO: PDF file buffer
    """
    from apps.events.models import EventRegistration
    from apps.reviews.models import Review

    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4)
    story = []
    styles = getSampleStyleSheet()

    # Custom styles
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#2C3E50'),
        spaceAfter=30,
        alignment=TA_CENTER
    )

    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=16,
        textColor=colors.HexColor('#34495E'),
        spaceAfter=12,
        spaceBefore=12
    )

    # Title
    story.append(Paragraph("Волонтерская книжка", title_style))
    story.append(Spacer(1, 0.2 * inch))

    # User info
    story.append(Paragraph("Личная информация", heading_style))
    user_info = [
        ['ФИО:', f"{user.first_name} {user.last_name}"],
        ['Email:', user.email],
        ['Телефон:', user.phone or 'Не указан'],
        ['Локация:', user.location or 'Не указана'],
        ['Всего часов:', str(user.total_hours)],
        ['Рейтинг:', f"{user.rating:.1f}/5.0"],
    ]

    user_table = Table(user_info, colWidths=[2 * inch, 4 * inch])
    user_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#ECF0F1')),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 1, colors.grey),
    ]))
    story.append(user_table)
    story.append(Spacer(1, 0.3 * inch))

    # Events participated
    story.append(Paragraph("История участия в мероприятиях", heading_style))

    registrations = EventRegistration.objects.filter(
        volunteer=user,
        status__in=['approved', 'attended']
    ).select_related('event').order_by('-event__date')

    if registrations.exists():
        event_data = [['Дата', 'Название', 'Организатор', 'Часы', 'Статус']]

        for reg in registrations:
            event = reg.event
            event_data.append([
                event.date.strftime('%d.%m.%Y'),
                event.title[:40] + '...' if len(event.title) > 40 else event.title,
                event.organizer.get_full_name() or event.organizer.username,
                str(event.hours),
                'Посещено' if reg.status == 'attended' else 'Одобрено'
            ])

        event_table = Table(event_data, colWidths=[1.2 * inch, 2.5 * inch, 1.5 * inch, 0.8 * inch, 1 * inch])
        event_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#3498DB')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
        ]))
        story.append(event_table)
    else:
        story.append(Paragraph("Нет записей об участии в мероприятиях", styles['Normal']))

    story.append(Spacer(1, 0.3 * inch))

    # Reviews received
    story.append(Paragraph("Отзывы", heading_style))

    reviews = Review.objects.filter(
        target_user=user,
        moderation_status='approved'
    ).select_related('reviewer').order_by('-created_at')[:10]

    if reviews.exists():
        for review in reviews:
            review_text = f"<b>{review.reviewer.get_full_name() or review.reviewer.username}</b> ({review.rating}/5): {review.text[:200]}"
            story.append(Paragraph(review_text, styles['Normal']))
            story.append(Spacer(1, 0.1 * inch))
    else:
        story.append(Paragraph("Нет отзывов", styles['Normal']))

    story.append(Spacer(1, 0.3 * inch))

    # Footer
    footer_text = f"Документ сгенерирован {timezone.now().strftime('%d.%m.%Y %H:%M')}"
    story.append(Paragraph(footer_text, styles['Italic']))

    # Build PDF
    doc.build(story)
    buffer.seek(0)

    return buffer
