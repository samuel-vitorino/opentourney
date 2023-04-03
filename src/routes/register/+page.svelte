<script>
    import { PUBLIC_API_URL } from '$env/static/public';
    let name = '';
    let email = '';
    let pwd = '';
    let role = 0;

    const handleSubmit = async () => {
        const response = await fetch(`${PUBLIC_API_URL}/users`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user: { name, email, pwd, role }})
        });

        if (response.ok) {
            alert('Registration successful!');
        } else {
            alert('Registration failed!');
        }
    }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <label>
    Username:
    <input type="text" bind:value={name} required>
  </label>
  <label>
    Email:
    <input type="email" bind:value={email} required>
  </label>
  <label>
    Password:
    <input type="password" bind:value={pwd} required>
  </label>
  <button type="submit">Register</button>
</form>