from flask import Flask, render_template, request, jsonify
import os
import random

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY', 'your-secret-key-change-in-production')

# Profile data
PROFILE_DATA = {
    'name': 'Sohaib Sohail',
    'title': 'DevOps Engineer at PwC',
    'location': 'London',
    'summary': 'Cloud Engineer with over 4 years of experience at PwC and Capgemini, specialising in Azure, AWS, Terraform, and CI/CD pipelines.',
    'skills': {
        'Cloud Platforms': ['Azure', 'AWS', 'GCP'],
        'Infrastructure as Code': ['Terraform (Terragrunt)', 'Helm'],
        'CI/CD': ['GitHub Actions', 'Azure DevOps', 'Jenkins', 'Drone CI'],
        'Programming': ['Python', 'JavaScript', 'Bash', 'SQL', 'PowerShell'],
        'DevSecOps': ['Checkov', 'TFLint', 'Terratest', 'Anchore', 'SonarQube'],
        'Monitoring': ['Azure Monitor', 'AWS CloudWatch', 'Log Analytics']
    },
    'certifications': [
        'Terraform Associate',
        'Azure Fundamentals Certified',
        'AWS Cloud Practitioner Certified'
    ],
    'experience_years': 4,
    'current_learning': 'Kubernetes (targeting CKA certification by Q3 2025)'
}

@app.route('/')
def home():
    """Home page with profile and snake game."""
    return render_template('home.html', profile=PROFILE_DATA)

@app.route('/game')
def game():
    """Snake game page."""
    return render_template('game.html', profile=PROFILE_DATA)

@app.route('/api/highscore', methods=['GET', 'POST'])
def highscore():
    """Handle high score for snake game."""
    if request.method == 'POST':
        data = request.get_json()
        score = data.get('score', 0)
        # In a real app, you'd save this to a database
        # For demo purposes, we'll just return success
        return jsonify({'status': 'success', 'message': f'Score {score} recorded!'})
    
    # Return a random high score for demo
    return jsonify({'highscore': random.randint(50, 200)})

@app.route('/health')
def health():
    """Health check endpoint."""
    return {'status': 'healthy', 'app': 'Sohaib Sohail Portfolio'}

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)