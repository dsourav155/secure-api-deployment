# app/main.py
from flask import Flask, request, jsonify
import jwt
import datetime
import os
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Use environment variable for secret key and port
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'fallback_secret_key')
PORT = int(os.environ.get('PORT', 5001))  # Default to 5001 if not specified

# In-memory user storage (replace with database in production)
users = {}

@app.route('/')
def home():
    """Home route with basic information."""
    return jsonify({
        'message': 'Welcome to Secure DevOps API',
        'status': 'running',
        'port': PORT
    }), 200

@app.route('/register', methods=['POST'])
def register():
    """User registration endpoint."""
    data = request.json
    
    # Validate input
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'message': 'Missing username or password'}), 400
    
    if data['username'] in users:
        return jsonify({'message': 'User already exists'}), 400
    
    # Hash password before storing
    hashed_password = generate_password_hash(data['password'], method='sha256')
    users[data['username']] = hashed_password
    
    return jsonify({'message': 'User registered successfully'}), 201

@app.route('/login', methods=['POST'])
def login():
    """User login endpoint with JWT token generation."""
    data = request.json
    
    # Validate input
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'message': 'Missing username or password'}), 400
    
    # Check credentials
    if (data['username'] in users and 
        check_password_hash(users[data['username']], data['password'])):
        
        # Generate token with 1-hour expiration
        token = jwt.encode({
            'user': data['username'],
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)
        }, app.config['SECRET_KEY'], algorithm='HS256')
        
        return jsonify({'token': token}), 200
    
    return jsonify({'message': 'Invalid credentials'}), 401

@app.route('/users', methods=['GET'])
def get_users():
    """Endpoint to list registered usernames."""
    return jsonify({'users': list(users.keys())}), 200

if __name__ == '__main__':
    # Run the application
    print(f"Starting server on port {PORT}")
    app.run(host='0.0.0.0', port=PORT, debug=os.environ.get('FLASK_DEBUG', False))