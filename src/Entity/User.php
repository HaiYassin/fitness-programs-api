<?php

namespace App\Entity;

/**
 * Entité User avec validation d'email
 */
class User
{
    private string $email;

    public function setEmail(string $email): void
    {
        // Validation de l'email
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException('Email invalide');
        }
        
        $this->email = $email;
    }

    public function getEmail(): string
    {
        return $this->email;
    }
}
