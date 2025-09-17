<?php

namespace App\Tests\Unit\Entity;

use App\Entity\User;
use PHPUnit\Framework\TestCase;

class UserTest extends TestCase
{
    /**
     * Un User peut être créé avec un email
     */
    public function testUserCanBeCreatedWithEmail(): void
    {
        // Given - Préparer les données
        $email = 'john.doe@example.com';
        
        // When - Exécuter l'action
        $user = new User();
        $user->setEmail($email);
        
        // Then - Vérifier le résultat
        $this->assertEquals($email, $user->getEmail());
        $this->assertInstanceOf(User::class, $user);
    }

    /**
     * Un User ne peut pas avoir un email invalide
     */
    public function testUserCannotHaveInvalidEmail(): void
    {
        // Given - Email invalide
        $invalidEmail = 'invalid-email';
        
        // When & Then - On s'attend à une exception
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Email invalide');
        
        $user = new User();
        $user->setEmail($invalidEmail);
    }

        /**
     * Un User peut avoir un ID
     */
    public function testUserCanHaveId(): void
    {
        // Given
        $user = new User();
        $id = 123;
        
        // When
        $user->setId($id);
        
        // Then
        $this->assertEquals($id, $user->getId());
    }
}
