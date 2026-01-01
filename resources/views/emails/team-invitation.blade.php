<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Team Invitation</title>
</head>
<body style="font-family: sans-serif; background-color: #f3f4f6; padding: 20px;">
    <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);">
        <h2 style="color: #10b981; margin-top: 0;">You have been invited to join a team!</h2>
        
        <p style="color: #374151; line-height: 1.5;">
            You have been invited to join the <strong>{{ $invitation->team->name }}</strong> team on OurFuture.
        </p>

        <p style="color: #374151; line-height: 1.5;">
            By joining this team, you will be able to collaborate on financial goals, track assets, and manage transactions together.
        </p>

        <div style="margin: 30px 0;">
            <a href="{{ $acceptUrl }}" style="background-color: #10b981; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;">
                Accept Invitation
            </a>
        </div>

        <p style="color: #6b7280; font-size: 14px; margin-top: 30px;">
            If you did not expect to receive an invitation to this team, you may discard this email.
        </p>
    </div>
    
    <div style="text-align: center; margin-top: 20px; color: #9ca3af; font-size: 12px;">
        &copy; {{ date('Y') }} OurFuture SaaS. All rights reserved.
    </div>
</body>
</html>
